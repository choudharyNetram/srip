from flask import Flask, request, jsonify
from flask_socketio import SocketIO, emit, join_room
import cv2
import numpy as np
import tensorflow as tf
import base64
from PIL import Image, UnidentifiedImageError
from io import BytesIO
import os
import matplotlib as plt 
import pandas as pd
from sklearn.model_selection import train_test_split
from keras.utils import to_categorical
from keras.callbacks import ModelCheckpoint
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
import time 
import concurrent.futures


import eventlet

app = Flask(__name__)
#socketio = SocketIO(app, async_mode='eventlet')
socketio = SocketIO(app, max_http_buffer_size=100 * 1024 * 1024, async_mode='eventlet')  # 100 MB



# Load pre-trained models
face_cascade = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")
eye_cascade = cv2.CascadeClassifier("haarcascade_eye.xml")
#model = tf.keras.models.load_model('saved_model_1/saved_model_1/saved_model.h5')
model = tf.keras.models.load_model('./calibrated-user-models/final_model.h5')


def CustomParser(data):    
    j = np.asarray(data, dtype="int32").flatten()
    return j


# first append all data into some matrix 
datagen = [
    ImageDataGenerator()
]

user_data = None  # Global variable

@socketio.on('message')
def handle_message(data):
    print('Received message:', data)
    emit('response', {'data': 'Message received!'})

@socketio.on('json')
def handle_json(json):
    print('Received JSON:', json)
    emit('response', {'data': 'JSON received!'})

@socketio.on('my_event')
def handle_my_custom_event(json):
    print('Received custom event:', json)
    emit('response', {'data': 'Custom event received!'})

@socketio.on('connect')
def handle_connect():
    print('Connected to client')



@socketio.on('predicts')
def predicts(data):
    print('this is the predicts')
    print(data)
    emit('prediction_results', { "ram" : (2,3,4)})
    print("completed")


@socketio.on('image_data')
def handle_image_data(data):
    print('Received image data')
    image_data = data.get('image')
    if image_data:
        # Decode the base64 string to bytes
        image_bytes = base64.b64decode(image_data)
        with open("received_image.jpg", "wb") as f:
            f.write(image_bytes)
        print('Image saved successfully')
        emit('response', {'data': 'Image received and saved!'})
    else:
        emit('response', {'data': 'No image data received'})


@socketio.on('predict')
def predict(data):
    # Handle prediction logic here
    print("function predict is called")
    if 'image' not in data:
        emit('prediction_results', {"error": "No image data provided"})
        return

    # Decode base64 image string
    base64_image = data['image']
    try:
        image_bytes = base64.b64decode(base64_image)
        image = Image.open(BytesIO(image_bytes)).convert('RGB')
        image = image.rotate(90, expand=True)
        image = np.array(image)
    except (UnidentifiedImageError, Exception) as e:
        emit('prediction_results', {"error": f"Error: Could not decode image data: {str(e)}"})
        return

    try: 
        gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
    except(Exception) as e:
        emit('prediction_results', {'error': "could not detect face and couldn't change color"})
        return
    predictions = []
    for (x, y, w, h) in faces:
        face_roi = gray[y:y+h, x:x+w]
        eyes = eye_cascade.detectMultiScale(face_roi)
        for (ex, ey, ew, eh) in eyes:
            eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
            eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
            
            image_shape = np.expand_dims(eye_roi, axis=-1).shape
            data = CustomParser(eye_roi)
            data = np.asarray([np.asarray(data.reshape(image_shape))])
            data = data / 255
            pred = model.predict(data)
            max_value = np.amax(pred[0])
            result = np.where(pred[0] == max_value)[0][0]
            
            predictions.append({
                "prediction": int(result),
            })
    print(predictions)
    emit('prediction_results', predictions)

@socketio.on('calibrate_start')
def calibrate_start(data):
    # Handle calibration start logic here
    global user_data
    user_data={'image':[],'quadrant':[]}
    if 'isStart' not in data:
        print('data doesnt have isStart ')
        emit('calibration_started', {"Error": 'Send the Yes to start calibration'})
        return
    emit('calibration_started', {'message': 'Calibration started'})



@socketio.on('calibrate')
def calibrate(data):
    # Handle calibration logic here
    global user_data
    if 'images' not in data:
        print('no image in data')
        emit('calibration_results', {"error": "No image data provided"})
        return
    if 'buttonNos' not in data:
        emit('calibration_results', {"error": "No button-number data provided"})
        return

    buttNos = data['buttonNos'] 
    # Decode base64 image string
    base64_images = data['images']
    
    for i in range(0,len(buttNos)):
        buttNo = buttNos[i] 
        base64_image = base64_images[i]
        image_bytes = base64.b64decode(base64_image)
        image = Image.open(BytesIO(image_bytes)).convert('RGB')
        image = image.rotate(180, expand=True)
        image = np.array(image)
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
        for (x, y, w, h) in faces:
            face_roi = gray[y:y+h, x:x+w]
            eyes = eye_cascade.detectMultiScale(face_roi)

            for (ex, ey, ew, eh) in eyes:
                if ex < w/2:  # Left eye
                    eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
                    eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
                    
                    image_shape = np.expand_dims(eye_roi, axis=-1).shape
                    data = CustomParser(eye_roi)
                    # print("data shape",data.shape)
                    data = np.asarray([np.asarray(data.reshape(image_shape))])
                    # print("data shape next",data.shape)
                    data = data / 255
                    # print("data shape next next",data.shape)
                    data=np.squeeze(data,axis=0)

                    #user_data['number'].append(count)
                    user_data['image'].append(data)
                    user_data['quadrant'].append(buttNo)
                    #print(user_data['quadrant'])
                    #path='calibration-data/'+str(quadrant)+'/'+str(time.time())+"left"+'.jpg'
                    # cv2.imwrite(path,eye_roi)

                    # count+=1
                    
                else:  # Right eye
                    eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
                    eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
                    
                    image_shape = np.expand_dims(eye_roi, axis=-1).shape
                    data = CustomParser(eye_roi)
                    # print("data shape",data.shape)
                    data = np.asarray([np.asarray(data.reshape(image_shape))])
                    # print("data shape next",data.shape)
                    data = data / 255
                    # print("data shape next next",data.shape)
                    data=np.squeeze(data,axis=0)

                    #user_data['number'].append(count)
                    user_data['image'].append(data)
                    user_data['quadrant'].append(buttNo)
                    #print(user_data['quadrant'])
    
    emit('calibration_results', {'results': "toke data for calibration "})



@socketio.on('calibrate_start_stream')
def calibrate_start_stream(data):
    # Handle calibration start logic here
    global user_data
    user_data={'image':[],'quadrant':[]}
    if 'isStart' not in data:
        print('data doesnt have isStart ')
        emit('calibration_started_stream', {"Error": 'Send the Yes to start calibration'})
        return
    print('now, calibration will start')
    emit('calibration_started_stream', {'message': 'Calibration started'})


@socketio.on('calibrate_stream')
def calibrate_stream(data):
    # Handle calibration logic here
    global user_data
    if 'images' not in data:
        print('no image in data')
        emit('calibration_results', {"error": "No image data provided"})
        return
    if 'buttonNos' not in data:
        emit('calibration_results', {"error": "No button-number data provided"})
        return

    buttNos = data['buttonNos'] 
    # Decode base64 image string
    base64_images = data['images']

    for i in range(0,len(buttNos)):
        buttNo = buttNos[i] 
        base64_image = base64_images[i]

        yuv_bytes = base64.b64decode(base64_image)
        width, height = 720, 480  # Adjust based on your actual image resolution (960, 720 for max)
        gray = np.frombuffer(yuv_bytes, dtype=np.uint8).reshape((height , width))
        gray = cv2.rotate(gray, cv2.ROTATE_180)
        gray = np.array(gray)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
        """ 
        image_bytes = base64.b64decode(base64_image)
        image = Image.open(BytesIO(image_bytes)).convert('RGB')
        image = image.rotate(180, expand=True)
        image = np.array(image)
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
        """
        for (x, y, w, h) in faces:
            face_roi = gray[y:y+h, x:x+w]
            eyes = eye_cascade.detectMultiScale(face_roi)

            for (ex, ey, ew, eh) in eyes:
                if ex < w/2:  # Left eye
                    eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
                    eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
                    
                    image_shape = np.expand_dims(eye_roi, axis=-1).shape
                    data = CustomParser(eye_roi)
                    # print("data shape",data.shape)
                    data = np.asarray([np.asarray(data.reshape(image_shape))])
                    # print("data shape next",data.shape)
                    data = data / 255
                    # print("data shape next next",data.shape)
                    data=np.squeeze(data,axis=0)

                    #user_data['number'].append(count)
                    user_data['image'].append(data)
                    user_data['quadrant'].append(buttNo)
                    #print(user_data['quadrant'])
                    #path='calibration-data/'+str(quadrant)+'/'+str(time.time())+"left"+'.jpg'
                    # cv2.imwrite(path,eye_roi)

                    # count+=1
                    
                else:  # Right eye
                    eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
                    eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
                    
                    image_shape = np.expand_dims(eye_roi, axis=-1).shape
                    data = CustomParser(eye_roi)
                    # print("data shape",data.shape)
                    data = np.asarray([np.asarray(data.reshape(image_shape))])
                    # print("data shape next",data.shape)
                    data = data / 255
                    # print("data shape next next",data.shape)
                    data=np.squeeze(data,axis=0)

                    #user_data['number'].append(count)
                    user_data['image'].append(data)
                    user_data['quadrant'].append(buttNo)
                    #print(user_data['quadrant'])
    
    #emit('calibration_results', {'results': "toke data for calibration "})





@socketio.on('train')
def train(data):
    # Handle training logic here
    global user_data
    if not user_data['image'] or not user_data['quadrant']:
        emit('training_error', {"Calibration error": "No calibration data present"})
        return

    # Ensure all lists in user_data are of the same length
    lengths = [len(user_data[key]) for key in user_data]

    if len(set(lengths)) > 1:
        emit('training_error', {"Calibration error": "Inconsistent data lengths in user_data"})
        return

    data = pd.DataFrame(user_data)
    data = pd.concat([data] * 10, ignore_index=True)
    data['image'] = data['image'].tolist()
    try:
        x = np.stack(data['image'])
    except ValueError as e:
        print("Error stacking images:", e)
        emit('training_error', {"Calibration error": "Error processing images"})
        return

    if len(data['image']) != x.shape[0]:
        print("Mismatch between data['image'] length and x length.")

    y = data.quadrant.to_numpy()
    print(len(y), 'length of data')
    y = np.asarray([np.asarray(cls.reshape(1)) for cls in y])
    y = to_categorical(y, 9)

    x = x.astype(np.float32)
    y = y.astype(np.float32)

    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.20, stratify=y)
    datagen_train = datagen[0].flow(x_train, y_train, batch_size=10)
    datagen_val = datagen[0].flow(x_test, y_test, batch_size=10)

    checkpoint_filepath = 'calibrated-user-models/best_model.h5'
    model_checkpoint_callback = ModelCheckpoint(
        filepath=checkpoint_filepath,
        save_weights_only=False,
        monitor='val_loss',
        mode='min',
        save_best_only=True)

    save_best_model = SaveBestModel()

    # Load the pre-trained model
    model = tf.keras.models.load_model('./saved_model_1/saved_model_1/saved_model.h5')

    history = model.fit(
        datagen_train,
        epochs=70,
        batch_size=128,
        steps_per_epoch=int(np.ceil(len(x) / float(32))),
        callbacks=[save_best_model, model_checkpoint_callback],
        validation_data=datagen_val
    )

    # Load the best weights
    model.set_weights(save_best_model.best_weights)

    # Predict and evaluate the model
    y_pred = model.predict(x_test,verbose=0)
    y_pred_labels = np.argmax(y_pred, axis=1)
    cm = confusion_matrix(np.argmax(y_test, axis=1), y_pred_labels)
    print(cm)

    # Save the final model in .h5 format
    model.save('calibrated-user-models/final_model.h5')
    """ 
    save_best_model = SaveBestModel()
    history = model.fit(
        datagen_train,
        epochs=70,
        batch_size=128,
        steps_per_epoch=int(np.ceil(len(x) / float(32))),
        callbacks=[save_best_model],
        validation_data=datagen_val
    )
    model.set_weights(save_best_model.best_weights)
    model.save('calibrated-user-models/' + str(1))
    y_pred = model.predict(x_test)
    y_pred_labels = np.argmax(y_pred, axis=1)
    cm = confusion_matrix(np.argmax(y_test, axis=1), y_pred_labels)
    print(cm)
    # plot_multilabel_confusion_matrix(cm)
    """

    training_accuracy = history.history['accuracy'][-1]
    validation_accuracy = history.history['val_accuracy'][-1]

    user_data = { 'image': [], 'quadrant': []}

    emit('training_results', {
        "result": "Model training completed",
        "training_accuracy": training_accuracy,
        "validation_accuracy": validation_accuracy
    })

class SaveBestModel(tf.keras.callbacks.Callback):
    global training_accuracy,validation_accuracy
    def __init__(self, save_best_metric='accuracy', this_max=False):
        self.save_best_metric = save_best_metric
        self.max = this_max
        if this_max:
            self.best_training = float('-inf')
            self.best_validation = float('-inf')
        else:
            self.best_training = float('inf')
            self.best_validation = float('inf')
        self.best_weights = None

    def on_epoch_end(self, epoch, logs=None):
        global training_accuracy,validation_accuracy
        training_metric_value = logs[self.save_best_metric]
        validation_metric_value = logs.get(f'val_{self.save_best_metric}')

        if self.max:
            flag1=False
            if training_metric_value > self.best_training:
                self.best_training = training_metric_value
                flag1=False
            if validation_metric_value is not None and ( validation_metric_value > self.best_validation or (validation_metric_value == self.best_validation and flag1)):
                self.best_validation = validation_metric_value
                self.best_weights = self.model.get_weights()
        else:
            flag2=False
            if training_metric_value < self.best_training:
                self.best_training = training_metric_value
                self.max=True
                flag2=True
            if validation_metric_value is not None and (validation_metric_value < self.best_validation or (validation_metric_value == self.best_validation and flag2))  :
                self.best_validation = validation_metric_value
                self.best_weights = self.model.get_weights()
                self.max=True
        training_accuracy=self.best_training
        validation_accuracy=self.best_validation



def plot_multilabel_confusion_matrix(confusion_matrix):
    class_names = ['C1', 'C2', 'C3', 'C4', 'C5', 'C6','C7','C8','C9']

    fig, ax = ConfusionMatrixDisplay(conf_mat=confusion_matrix,
                                    colorbar=True,
                                    show_absolute=True,
                                    show_normed=True,
                                    class_names=class_names)
    ax.set_xlabel("True Label")
    ax.set_ylabel("Predicted Label")
    plt.show()




# def yuv_to_rgb(yuv_bytes, width, height):
#     yuv_image = np.frombuffer(yuv_bytes, dtype=np.uint8).reshape((2*height , width))
#     rgb_image = cv2.cvtColor(yuv_image, cv2.COLOR_YUV2RGBA_YUY2) # COLOR_YUV2RGB_I420,   COLOR_YUV2RGBA_YUY2
#     return rgb_image


# def crop_top_30_percent(image):
#     height, width, _ = image.shape
#     crop_height = int(height * 0.27)
#     cropped_image = image[crop_height:, :]
#     return cropped_image
"""

def process_image(image_base64, index, total_time):
    yuv_bytes = base64.b64decode(image_base64)
    width, height = 960, 720  # Adjust based on your actual image resolution
    yuv_image = np.frombuffer(yuv_bytes, dtype=np.uint8).reshape((height, width))
    rotated_image = cv2.rotate(yuv_image, cv2.ROTATE_180)
    faces = face_cascade.detectMultiScale(rotated_image, scaleFactor=1.3, minNeighbors=5)

    selected = None
    eye1, eye2 = None, None

    for (x, y, w, h) in faces:
        face_roi = rotated_image[y:y+h, x:x+w]
        eyes = eye_cascade.detectMultiScale(face_roi)
        for (ex, ey, ew, eh) in eyes:
            
            if ew <= 0 or eh <= 0:
                continue  # Skip invalid eye regions
            eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
            if eye_roi.size == 0:
                continue 
            eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
            image_shape = np.expand_dims(eye_roi, axis=-1).shape
            data = np.asarray([eye_roi.reshape(image_shape)]) / 255
            predictions = model.predict(data )# verbose= 0 
            result = np.argmax(predictions[0])
            if ex < w/2:
                eye1 = result
            else:
                eye2 = result
                selected = result

    if eye1 != eye2:
        selected = None

    return selected, (index + 1) / total_time

@socketio.on('predict_ops_stream')
def predict_ops_stream(data):
    images = data['images']
    weights = np.zeros(9)
    total_time = 10

    with concurrent.futures.ThreadPoolExecutor() as executor:
        futures = {executor.submit(process_image, image_base64, i, total_time): i for i, image_base64 in enumerate(images)}
        prev = None

        for future in concurrent.futures.as_completed(futures):
            try:
                selected, weight = future.result()
                if selected is not None and (prev is None or prev == selected):
                    weights[selected] += weight
                elif selected is not None:
                    weights[selected] += weight
                prev = selected if selected is not None else None
            except Exception as e:
                print(f"Error processing image: {e}")
    weights_list = weights.tolist()
    emit('predict_weights', {
        "weights": weights_list,
    })


"""

weights = np.zeros(9)
i = 0 

@socketio.on('prediction_ops_start')
def prediction_start():
    global weights 
    global i 
    weights = np.zeros(9)
    i = 0 
    print('predict_ops_function_called')


@socketio.on('predict_ops_stream')
def predict_ops_stream(data):
    global weights 
    global i 
    

    images = data['images']
    images = images 
    total_time=8
    prev=None
   

    for image_base64 in images:
        yuv_bytes = base64.b64decode(image_base64)
        
        width, height = 720, 480  # Adjust based on your actual image resolution
        gray = np.frombuffer(yuv_bytes, dtype=np.uint8).reshape((height , width))
        #rgb_image = yuv_to_rgb(yuv_bytes, width, height)
        # Process the RGB image as needed
        #rgb_image = rgb_image.rotate(90, expand=True)
        gray = cv2.rotate(gray, cv2.ROTATE_180)
        #cropped_image = crop_top_30_percent(rotated_image)

        #cv2.write(rgb_image)
        # filename = f"image_{1}.jpg"
        # filepath = os.path.join(os.getcwd(), filename)
        # cv2.imwrite(filepath, rotated_image)

        gray = np.array(gray)
        # Save the RGB image
        #gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        # gray = rotated_image
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
        #cv2.imwrite(filepath2, gray)
        # print(faces)
        selected = None
        eye1=None
        eye2=None
        #print(faces)
        for (x, y, w, h) in faces:
            face_roi = gray[y:y+h, x:x+w]
            eyes = eye_cascade.detectMultiScale(face_roi)
            #print(eyes, "w", w)
            for (ex, ey, ew, eh) in eyes:
                if ex < w/2:  # Left eye
                    # print("left eye")
                    eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
                    eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
                    
                    image_shape = np.expand_dims(eye_roi, axis=-1).shape
                    data = CustomParser(eye_roi)
                    data = np.asarray([np.asarray(data.reshape(image_shape))])
                    data = data / 255
                    predictions = model.predict(data, verbose = 0)
                    #print("left", predictions)
                    # max_value = np.amax(predictions[0])
                    result = np.where(predictions[0] == np.amax(predictions[0]))[0]
                    eye1=result
                    # selected = result

                else:  # Right eye
                    # print("right-eye")
                    eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
                    eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
                    
                    image_shape = np.expand_dims(eye_roi, axis=-1).shape
                    data = CustomParser(eye_roi)
                    data = np.asarray([np.asarray(data.reshape(image_shape))])
                    data = data / 255
                    predictions = model.predict(data, verbose = 0)
                    #print("right", predictions)
                    #max_value = np.amax(predictions[0])
                    result = np.where(predictions[0] == np.amax(predictions[0]))[0]
                    eye2=result
                    selected = result
                    # print(result)

        # if eye1 != None:
        #     weights[eye1]+=((i+1)/total_time)
        # if eye2 != None: 
        #     weights[eye2]+=((i+1)/total_time)

        # print(eye1, eye2)

        if eye1!=eye2:
            selected=None
       
        if selected is not None:
            #change_border_colour(boxes[letters[prev]],0)
            weights[selected[0]]+=((i+1)/total_time)

        i += 1 
            #change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time))
         # if selected is not None and (prev is None or prev==selected[0]):
        #     #print("first")
        #     weights[selected[0]]+=((i+1)/total_time)
        #     #change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time))
        # if selected is not None:
        #     prev=selected[0]
        # else:
        #     prev=None
        
        

   
    weights_list = weights.tolist()
    emit('predict_weights', {
        "weights": weights_list,
        "iter": i , 
    })
    if i == 8 :
        i = 0 
        weights = np.zeros(9) 


@socketio.on('predict_ops')
def predict_ops(data):
    global weights 
    weights = np.zeros(9)    
    if 'images' not in data:
        print('no image in data')
        emit('predict_weights', {"error": "No image data provided"})
        return
    
    total_time=5
    prev=None

    base64_images = data['images']

    for i in range(len(base64_images)):
        try:
            image_bytes = base64.b64decode(base64_images[i])
            image = Image.open(BytesIO(image_bytes)).convert('RGB')
            image = image.rotate(180, expand=True)
            filename = f"image_{1}.jpg"
            filepath = os.path.join(os.getcwd(), filename)
            
            #image = image.rotate(90, expand=True)
            image = np.array(image)
            cv2.imwrite(filepath, image)
        except (UnidentifiedImageError, Exception) as e:
            print('oh see, the error ', str(e))
            emit('prediction_results', {"error": f"Error: Could not decode image data: {str(e)}"})
            return

        gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
        # filename = f"image_{2}.jpg"
        # filepath = os.path.join(os.getcwd(), filename)
        # cv2.imwrite(filepath, gray)
        
        selected = None
        eye1=None
        eye2=None
        for (x, y, w, h) in faces:
            face_roi = gray[y:y+h, x:x+w]
            eyes = eye_cascade.detectMultiScale(face_roi)
            
            for (ex, ey, ew, eh) in eyes:
                if ex < w/2:  # Left eye
                    eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
                    eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
                    
                    image_shape = np.expand_dims(eye_roi, axis=-1).shape
                    data = CustomParser(eye_roi)
                    data = np.asarray([np.asarray(data.reshape(image_shape))])
                    data = data / 255
                    predictions = model.predict(data)
                    max_value = np.amax(predictions[0])
                    result = np.where(predictions[0] == np.amax(predictions[0]))[0]
                    eye1=result
                    # selected = result

                else:  # Right eye
                    eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
                    eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
                    
                    image_shape = np.expand_dims(eye_roi, axis=-1).shape
                    data = CustomParser(eye_roi)
                    data = np.asarray([np.asarray(data.reshape(image_shape))])
                    data = data / 255
                    predictions = model.predict(data)
                    max_value = np.amax(predictions[0])
                    result = np.where(predictions[0] == np.amax(predictions[0]))[0]
                    eye2=result
                    selected = result
                    # print(result)

        if eye1!=eye2:
            selected=None

    
        if selected is not None and (prev is None or prev==selected[0]):
            #print("first")
            weights[selected[0]]+=((i+1)/total_time)
            #change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time))
        elif selected is not None:
            #print("second")
            #change_border_colour(boxes[letters[prev]],0)
            weights[selected[0]]+=((i+1)/total_time)
            #change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time))
        if selected is not None:
            prev=selected[0]
        else:
            prev=None
        """ 
        else:
            print("third")
            if prev!=None:
                pass 
                #change_border_colour(boxes[letters[prev]],0)

        current_total+=((i+1)/total_time)

        remaining=totalWeight-current_total

        if(selected is not None and ((remaining+weights.argmax())/totalWeight)<Threshold):
            print("fourth")
            #change_border_colour(boxes[letters[selected[0]]],0)

        if selected is not None:
            prev=selected[0]
        else:
            prev=None
        
        counter+=1
        """
    weights_list = weights.tolist()
    emit('predict_weights', {
        "weights": weights_list,
    })


if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000, debug=False)
