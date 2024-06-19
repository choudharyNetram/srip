from flask import Flask, request, jsonify
import cv2
import numpy as np
import tensorflow as tf
import base64
from PIL import Image, UnidentifiedImageError
from io import BytesIO
import os
import pandas as pd 
import matplotlib as plt 
from sklearn.model_selection import train_test_split
from sklearn.metrics import confusion_matrix
# from sklearn.metrics import plot_confusion_matrix
from keras.utils import to_categorical 
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from sklearn.metrics import confusion_matrix, ConfusionMatrixDisplay
import time 
import json


app = Flask(__name__)

# Load pre-trained models
face_cascade = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")
eye_cascade = cv2.CascadeClassifier("haarcascade_eye.xml")
model = tf.keras.models.load_model('saved_model_1/saved_model_1/saved_model.h5')

def CustomParser(data):    
    j = np.asarray(data, dtype="int32").flatten()
    return j

@app.route('/')
def index():
    return "Hello, world!"


@app.route('/predict', methods=['POST'])
def predict():
    data = request.get_json()
    if 'image' not in data:
        return jsonify({"error": "No image data provided"}), 400

    # Decode base64 image string
    base64_image = data['image']
    try:
        image_bytes = base64.b64decode(base64_image)
        image = Image.open(BytesIO(image_bytes)).convert('RGB')
        image = image.rotate(90, expand=True)
        image = np.array(image)
    except (UnidentifiedImageError, Exception) as e:
        return jsonify({"error": f"Error: Could not decode image data: {str(e)}"}), 400

    try: 
        gray = cv2.cvtColor(image, cv2.COLOR_RGB2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
    except(Exception) as e:
        return jsonify({'error': "could not detect face and couldn't change color"})
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
    
    return jsonify(predictions)




# first append all data into some matrix 
datagen = [
    ImageDataGenerator()
]

user_data = None  # Global variable

@app.route('/calibrateStart', methods=['POST'])
def calibrationStart():
    global user_data
    user_data={'image':[],'quadrant':[]}
    data = request.get_json() 
    if 'isStart' not in data:
        return jsonify({"Error": 'Send the Yes to start calibration'}), 400 
    return jsonify({"result": 'server is connected'}) ,   200 


@app.route('/calibrate', methods=['POST'] )
def calibrate():
    global user_data
    data = request.get_json()
    if 'images' not in data:
        return jsonify({"error": "No image data provided"}), 400
    if 'buttonNos' not in data:
        return jsonify({"error": "No button-number data provided"}), 400

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
    print(user_data['quadrant'])
    return jsonify({'results': "toke data for calibration "}), 200

@app.route('/train', methods=['POST'])
def train():
    global user_data
    if not user_data['image'] or not user_data['quadrant']:
        return jsonify({"Calibration error": "No calibration data present"}), 400

    # Ensure all lists in user_data are of the same length
    lengths = [len(user_data[key]) for key in user_data]

    if len(set(lengths)) > 1:
        return jsonify({"Calibration error": "Inconsistent data lengths in user_data"}) , 400

    data = pd.DataFrame(user_data)
    data['image'] = data['image'].tolist()
    
    try:
        x = np.stack(data['image'])
    except ValueError as e:
        print("Error stacking images:", e)
        return jsonify({"Calibration error": "Error processing images"}), 400

    if len(data['image']) != x.shape[0]:
        print("Mismatch between data['image'] length and x length.")

    y = data.quadrant.to_numpy()
    y = np.asarray([np.asarray(cls.reshape(1)) for cls in y])
    y = to_categorical(y, 9)

    x = x.astype(np.float32)
    y = y.astype(np.float32)

    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.20, stratify=y)
    datagen_train = datagen[0].flow(x_train, y_train, batch_size=10)
    datagen_val = datagen[0].flow(x_test, y_test, batch_size=10)

    save_best_model = SaveBestModel()
    history = model.fit(
        datagen_train,
        epochs=70,
        batch_size=128,
        steps_per_epoch=int(np.ceil(len(x) / float(32))),
        callbacks=[save_best_model],
        validation_data=datagen_val
    )
    """ 
    plt.plot(history.history['accuracy'])
    plt.plot(history.history['val_accuracy'], color="green")
    plt.title('Model Accuracy')
    plt.ylabel('Accuracy')
    plt.xlabel('Epoch')
    plt.legend(['Training', 'Validation'], loc='upper left')
    plt.show()

    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('Model Loss')
    plt.ylabel('Loss')
    plt.xlabel('Epoch')
    plt.legend(['Training', 'Validation'], loc='upper left')
    plt.show()
    """
    model.set_weights(save_best_model.best_weights)
    model.save('calibrated-user-models/' + str(1))
    y_pred = model.predict(x_test)
    y_pred_labels = np.argmax(y_pred, axis=1)
    cm = confusion_matrix(np.argmax(y_test, axis=1), y_pred_labels)
    print(cm)
    # plot_multilabel_confusion_matrix(cm)

    training_accuracy = history.history['accuracy'][-1]
    validation_accuracy = history.history['val_accuracy'][-1]

    user_data = { 'image': [], 'quadrant': []}

    return jsonify({
        "result": "Model training completed",
        "training_accuracy": training_accuracy,
        "validation_accuracy": validation_accuracy
    }), 200

    



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



""" 

def train_calibrate():
    global user_data
    data = pd.DataFrame(user_data)
    data['image'] = data['image'].tolist()
    try:
        x = np.stack(data['image'])
    except ValueError:
        return jsonify({"Calibration error":  "Calibration data is not present"})

    if len(data['image']) != x.shape[0]:
        print("Mismatch between data['image'] length and x length.")
    
    y = data.quadrant.to_numpy()
    y=np.asarray([np.asarray(cls.reshape(1)) for cls in y])
    y = to_categorical(y, 9)

    x = x.astype(np.float32) 
    y = y.astype(np.float32) 

    x_train, x_test, y_train, y_test= train_test_split(x, y, test_size= 0.20,stratify=y)
    datagen_train = datagen[0].flow(x_train, y_train, batch_size=10)
    datagen_val = datagen[0].flow(x_test, y_test, batch_size=10)
    
    # print(np.bincount(y_test))
    save_best_model=SaveBestModel()

    history=model.fit(
        datagen_train,
        epochs=70,
        batch_size=128,
        steps_per_epoch=int(np.ceil(len(x) / float(32))),callbacks=[save_best_model],
        validation_data=datagen_val
    )
    plt.plot(history.history['accuracy'])
    plt.plot(history.history['val_accuracy'],color="green")
    plt.title('model accuracy')
    plt.ylabel('Accuracy')
    plt.xlabel('Epoch')
    plt.legend(['Training', 'Validation'], loc='upper left')
    plt.show()

    plt.plot(history.history['loss'])
    plt.plot(history.history['val_loss'])
    plt.title('model loss')
    plt.ylabel('Loss')
    plt.xlabel('Epoch')
    plt.legend(['Training', 'Testing'], loc='upper left')
    plt.show()
    model.set_weights(save_best_model.best_weights)
    model.save('calibrated-user-models/'+str(1))
    global training_accuracy,validation_accuracy
    y_pred= model.predict(x_test)
    y_pred_labels = np.argmax(y_pred, axis=1)
    # y_pred = to_categorical(np.argmax(y_pred, axis=1), num_classes=9)
    cm = confusion_matrix(np.argmax(y_test, axis=1), y_pred_labels)
    print(cm)
    print("Training accuracy :",training_accuracy)
    plot_multilabel_confusion_matrix(cm)
    # calibration_rating(validation_accuracy)
    user_data={'number':[],'image':[],'quadrant':[]}

"""


""" 



def calibration(box,frames):
    # tk.Message("Please look at the green box for some time")
    #global quadrant
    global user_data
    # camera= cv2.VideoCapture(0)
    counter=0
    select=0
    # total_frames=frames
    count=0
    while(count<frames):
        # if(counter==10):
        #     counter=0
        #     select=1-select
        # if(select%2==0):
        #     box.config(width=2,height=1)āśśś
        # else:
        #     box.config(width=4,height=2)

        # if(count%20==0):
        #     red_boxes[quadrant].config(foreground="lawn green")
        # elif(count%10==0):
        #     red_boxes[quadrant].config(foreground="forest green")

        #return_value, image=camera.read()
        # img = image
        # img=cv2.flip(img,1)
        data = request.get_json()
        if 'image' not in data:
            return jsonify({"error": "No image data provided"}), 400
        if 'buttonNo' not in data:
            return jsonify({"error": "No button-number data provided"}), 400

        # Decode base64 image string
        base64_image = data['image']
        image_bytes = base64.b64decode(base64_image)
        image = Image.open(BytesIO(image_bytes)).convert('RGB')
        image = image.rotate(90, expand=True)
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

                    user_data['number'].append(count)
                    user_data['image'].append(data)
                    user_data['quadrant'].append(quadrant)

                    #path='calibration-data/'+str(quadrant)+'/'+str(time.time())+"left"+'.jpg'
                    # cv2.imwrite(path,eye_roi)

                    count+=1
                    
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

                    user_data['number'].append(count)
                    user_data['image'].append(data)
                    user_data['quadrant'].append(quadrant)

            

                    # path='calibration-data/'+str(quadrant)+'/'+str(time.time())+"right"+'.jpg'
                    # cv2.imwrite(path,eye_roi)

                    count+=1
            
        counter+=1
    quadrant+=1






def calibration_rating(accuracy):
    print("Validation accuracy : ",accuracy)
    global rating_frame,rating_star_white,rating_star_yellow,rating_buttons
    rating_frame=tk.Frame(root,bg='black',highlightthickness=4,highlightbackground="white",highlightcolor="white",padx=10,pady=10)
    rating_frame.grid(row=2,column=1)
    
    rating_label=tk.Label(rating_frame,text="Calibration Rating :",bg='black',foreground='white',font=('Aerial',16))
    rating_label.grid(row=0,column=0)


    rating=None
    count=None
    if   0 <= int(accuracy*100) <= 80 :
        rating="Re-Calibrate"
        count=1
    elif 81 <= int(accuracy*100) <=85 :
        rating="Poor"
        count=2
    elif 86 <= int(accuracy*100) <=90 :
        rating="Moderate"
        count=3
    elif 91 <= int(accuracy*100) <=95:
        rating="Good"
        count=4
    elif 96 <= int(accuracy*100) <=100:
        rating="Excellent"
        count=5


    yellow_stars=str(rating)
    yellow_stars+=" "
    yellow_stars+=count*"⭐"
    white_stars="⭐"*(5-count)
    rating_star_yellow=tk.Label(rating_frame,text=yellow_stars, bg='black',foreground='yellow',highlightthickness=0,bd=0,font=('Aerial',16))
    rating_star_white=tk.Label(rating_frame,text=white_stars, bg='black',foreground="gray31",highlightthickness=0,bd=0,font=('Aerial',16))
    rating_star_yellow.grid(row=0,column=1)
    rating_star_white.grid(row=0,column=2)

    rating_buttons=tk.Frame(rating_frame,bg='black')
    rating_buttons.grid(row=1,column=0)

    accept_button=tk.Button(rating_buttons,text="Accept",command=accept_calibration, bg='black',foreground='white')
    accept_button.grid(row=0,column=0,padx=(2,10), pady=5)

    redo_button=tk.Button(rating_buttons,text="Re-Calibrate",command=redo_calibration, bg='black',foreground='white')
    redo_button.grid(row=0,column=1)
"""
""" 
def calibrate():
    data = request.get_json()
    if 'image' not in data:
        return jsonify({"error": "No image data provided"}), 400
    if 'buttonNo' not in data:
        return jsonify({"error": "No button-number data provided"}), 400

    # Decode base64 image string
    base64_image = data['image']
    return jsonify({'output': 'Got the image streams', 'buttonNo':data['buttonNo']}), 200 
"""


@app.route('/nextOperation', methods=['POST'])
def next_operation():
    predictions = []
    
    pass 




@app.route('/model_info', methods=['GET'])
def model_info():
    model_info = []
    for layer in model.layers:
        layer_info = {
            'name': layer.name,
            'class_name': layer.__class__.__name__,
            'output_shape': getattr(layer.output, 'shape', 'N/A'),
            'params': layer.count_params(),
            'trainable': layer.trainable
        }
        model_info.append(layer_info)
    return jsonify(model_info)


@app.route('/predictMany', methods=['POST'])
def predictMany():
    data = request.get_json()
    if 'image' not in data:
        return jsonify({"error": "No image data provided"}), 400

    # Decode base64 image string
    base64_image = data['image']
    print(base64_image[0:200])
    try:
        image_bytes = base64.b64decode(base64_image)
        print(f"Image bytes length: {len(image_bytes)}")
        print(image_bytes[0:20])
        image_width = data.get('width')  # Extract width from JSON payload
        image_height = data.get('height')
        print(image_height)
        print(image_width)
       
    except (UnidentifiedImageError, Exception) as e:
        return jsonify({"error": f"Error: Could not decode image data: {str(e)}"}), 400
    
    try: 
         # Convert YUV420 to RGB
        # Replace desired_width and desired_height with your desired dimensions
        
        yuv_image = np.frombuffer(image_bytes, dtype=np.uint8).reshape((image_height + image_height // 2, image_width))
        print("converted to yuv image")
        rgb_image = cv2.cvtColor(yuv_image, cv2.COLOR_YUV2RGB_I420)
        print("this is rgb" , rgb_image[0:20])
        desired_width = 4128 
        desired_height = 3096
        # Resize the image to a fixed size
        # resized_image = cv2.resize(rgb_image, (desired_width, desired_height)) 

        gray = cv2.cvtColor(rgb_image, cv2.COLOR_RGB2GRAY)
        faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
        print("starting predictions")
    except ( Exception) as e:
        return jsonify({"error": f"Error: Could not resize the image data: {str(e)}"}), 400
    
    
    predictions = []
    print(faces)
    for (x, y, w, h) in faces:
        face_roi = gray[y:y+h, x:x+w]
        eyes = eye_cascade.detectMultiScale(face_roi)
        for (ex, ey, ew, eh) in eyes:
            eye_roi = face_roi[ey:ey+eh, ex:ex+ew]
            eye_roi = cv2.resize(eye_roi, (100, 100), interpolation=cv2.INTER_LINEAR)
            
            image_shape = np.expand_dims(eye_roi, axis=-1).shape
            data = np.asarray([np.asarray(eye_roi).reshape(image_shape)])
            data = data / 255
            pred = model.predict(data)
            print(pred)
            max_value = np.amax(pred[0])
            result = np.where(pred[0] == max_value)[0][0]
            predictions.append({
                "eye_position": "left" if ex < w/2 else "right",
                "prediction": int(result),
                "confidence": float(max_value)
            })
    
    print(predictions)
    return jsonify(predictions)


@app.route('/saveImage', methods=['POST'])
def saveImage():
    data = request.get_json()
    if 'image' not in data:
        return jsonify({"error": "No image data provided"}), 400

    # Decode base64 image string
    base64_image = data['image']
    try:
        image_bytes = base64.b64decode(base64_image)
        print(f"Image bytes length: {len(image_bytes)}")
        image = Image.open(BytesIO(image_bytes)).convert('RGB')
        image = image.rotate(90, expand=True)
        image = np.array(image)
    except (UnidentifiedImageError, Exception) as e:
        return jsonify({"error": f"Error: Could not decode image data: {str(e)}"}), 400

    # Save the image as a .jpg file in the Flask directory
    image_path = os.path.join(os.getcwd(), "received_image.jpg")
    try:
        Image.fromarray(image).save(image_path)
        print(f"Image saved as {image_path}")
    except Exception as e:
        return jsonify({"error": f"Error: Could not save image: {str(e)}"}), 500

    # Further processing and predictions...
    # (Remaining code for face detection and predictions)

    return jsonify({"message": "Image received and saved successfully", "image_path": image_path})


@app.route('/withImgPath', methods=['POST'])
def withImgPath():
        
    os.chdir("C:/Users/choud/App_dev/flutter_application_1")
    img = cv2.imread('image.jpg')
    img=cv2.flip(img,1)         
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
    print("starting predictions")
    predictions = []
    print(faces)
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
                "eye_position": "left" if ex < w/2 else "right",
                "prediction": int(result),
                "confidence": float(max_value)
            })
    
    print(predictions)
    return jsonify(predictions)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
