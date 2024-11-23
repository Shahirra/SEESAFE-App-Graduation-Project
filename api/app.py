from flask import Flask, request, jsonify
import requests#, tensorflow as tf
import base64, cv2
from ultralytics import YOLO
from PIL import Image
from io import BytesIO
import matplotlib.pyplot as plt
import os
# from backend.boundary_box import BoundaryBox
from Classes import Labels

model = YOLO('E:\College\GradProj\github_ws\Blind-App\model\yolov8s.pt') # add your own path
Classes = Labels().classes

predicted_bboxes = {}

def predict(img):
    predictions = model.track(source=img, show=True, persist=True, conf=.7)
    return predictions
    
def getBBoxFromPrediction(predictions):
    boxes = predictions[0].boxes

    if boxes and len(boxes) > 0:
        i = 0
        for box in boxes:
            x, y, w, h = box.xywh.cpu().numpy()[0]
            y = y + h
            predicted_bboxes['box{}'.format(i)] = {'id':int(box.id.cpu().numpy()[0].item()),
                                        'xywh':[x.item(), y.item(), w.item(), h.item()],
                                        'className': Classes[int(box.cls[0])]}
            i +=1

        return predicted_bboxes
    return

def showResults(predictions):
    frame = predictions[0].plot()
    cv2.imshow("predictions view", frame)
    return frame

app = Flask(__name__)

@app.route('/api', methods = ['GET'])
def returnString():
    print("API req recieved")
    return "hi api on fire"

@app.route('/api/uploadImage', methods = ['POST'])
def run_model():
    
    input_base64 = request.get_data()
    if not input_base64:
        print('error Missing image')
        return jsonify({'error': 'Missing image data'}), 400
    
    try:
        img_decoded = base64.b64decode(input_base64)
    except Exception as e:
        print('error decoding message')
        return jsonify({'error': 'Invalid base64 - {}'.format(str(e))}), 400
    
    file_name = 'received_image.jpg'
    with open(file_name, 'wb') as f:
        f.write(img_decoded)
    img = cv2.imread('received_image.jpg')
    img_rotated = cv2.rotate(img, cv2.ROTATE_90_CLOCKWISE)
    cv2.imwrite('rotated_image.jpg', img_rotated)
    
    
    predictions = predict(img=img_rotated)
    frame = showResults(predictions)
    bboxs = getBBoxFromPrediction(predictions=predictions)
    if bboxs:
        return jsonify(bboxs)
    return jsonify('no predictions')


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)


