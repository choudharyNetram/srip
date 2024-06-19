from flask import Flask, request, jsonify
import cv2
import numpy as np
import tensorflow as tf
import base64
from PIL import Image, UnidentifiedImageError
from io import BytesIO
import os

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



total_time3=10
d1=(2/total_time3)-(1/total_time3)
a1=(1/total_time3)
n1=total_time3
totalWeight1=(n1)/(2*(2*a1+(n1-1)*d1))

b23=3
e33=0.5
e43=0.9
Pselect3=[]
not_selected3=0


def process_image11():
    global selectedBox,camera
    selectedBox=None
    global total_time3,d1,a1,n1,totalWeight1,detail2_ans,letters
    total_time3=10
    not_selected3=0
    Pselect3=[]
    center=False
    while not stop_processing.is_set():
        if(len(Alldata["Quadrant"]))!=0:
            if(np.average(Pselect3)>e43 and total_time3>7):
                total_time3-=b23
            if((not_selected3/(not_selected3+len(Alldata["Quadrant"])))>=e33 and total_time3<28):
                total_time3+=b23
            if((np.sum([1 for i in Alldata["Quadrant"] if i==8])/len(Alldata["Quadrant"]) >= e33 and total_time3<28)):
                total_time3+=b23
        current_total=0.0

        d1=(2/total_time3)-(1/total_time3)
        a1=(1/total_time3)
        n1=total_time3
        totalWeight1=(n1)/(2*(2*a1+(n1-1)*d1))
       
        

        # if not center:
        #     data=str(text1.get("1.0","end-1c"))
        #     # data1=str(text2.get("1.0","end-1c"))
        #     text1.delete('1.0',tk.END)
        #     text1.insert(tk.END,data)
        #     # text2.delete('1.0',tk.END)
        #     # text2.insert(tk.END,data1)
        #     center=False


        # if selectedBox!=None:
        #     root.after(10, change_border_colour(selectedBox,0))

        start1=time.time()
        counter=0
        prev=None
        weights=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        weights=np.array(weights)
        for i in range(total_time3):
            
            return_value, image=camera.read()
            img = image
            img=cv2.flip(img,1)         
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)

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
                        selected = result

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

            if selected is not None and selected[0]==4:
                selected=None

            if selected is not None and (prev is None or prev==selected[0]):
                weights[selected[0]]+=((i+1)/total_time3)
                change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time3))
            elif selected is not None:
                change_border_colour(boxes[letters[prev]],0)
                weights[selected[0]]+=((i+1)/total_time3)
                change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time3))
            else:
                if prev!=None:
                    change_border_colour(boxes[letters[prev]],0)

            current_total+=((i+1)/total_time3)

            remaining=totalWeight1-current_total
            
            if selected is not None:
                prev=selected[0]
            else:
                prev=None

            remaining=totalWeight1-current_total
            if(selected is not None and ((remaining+weights.argmax())/totalWeight1)<Threshold):
                change_border_colour(boxes[letters[selected[0]]],0)
                break
            
            counter+=1
        
        end1=time.time()
        # print(end1-start1,counter)
        if prev!=None:
                change_border_colour(boxes[letters[prev]],0)
        Max=weights.argmax()
        if(sum(weights)>0 and (weights[Max]/sum(weights))>=Threshold):
            selected=[Max]
            Pselect3.append((weights[Max]/sum(weights)))
            
        else :
            if selected is not None:
                change_border_colour(boxes[letters[selected[0]]],0)
            elif prev!=None:
                change_border_colour(boxes[letters[prev]],0)
            not_selected3+=1
            selected =None

        if selected is not None:
            selectedBox=boxes[letters[selected[0]]]
            change_border_colour(boxes[letters[selected[0]]],0)

            if selected[0]==8:
                Delete()
                play_audio(letters[selected[0]])
                level_change(selected,0)

            if selected[0]==4:
                center=True

            if selected[0]!=8 and selected[0]!=4:
                # time.sleep(1)
                level_change(selected,1)
             

            


                
            Time=time.time()-startTime
            Alldata["Time"].append(str(round(Time,2)))
            Alldata["Frames"].append(str(total_time3))
            Alldata["Quadrant"].append(str(selected[0]))
            Alldata["letter"].append(keystrokes)
            ITRletter=math.log2(TotalLetters)*(len(keystrokes)/(Time/60))
            Alldata["ITRletter"].append(str(round(ITRletter,2)))
            ITRcommand=math.log2(TotalCommands)*(len(Alldata["Quadrant"])/(Time/60))
            Alldata["ITRcommand"].append(str(round(ITRcommand,2)))
            TER=ITRletter/math.log2(TotalLetters)
            Alldata["TER"].append(str(round(TER,2)))
            Alldata["ctime"].append(str(0))
            Alldata["meanx"].append(str(0))
            Alldata["meany"].append(str(0))
            Alldata["stdx"].append(str(0))
            Alldata["stdy"].append(str(0))
            Alldata["meanlp"].append(str(0))
            Alldata["meanrp"].append(str(0))
            Alldata["stdlp"].append(str(0))
            Alldata["stdrp"].append(str(0))
            # global detail2,detail3,detail4
            # detail2.config(text="Total Time : "+str(round(Time,2)))
            # detail3.config(text="ITR Letter: "+str(round(ITRletter,2)))
            # detail4.config(text="ITR Command: "+str(round(ITRcommand,2)))

            if selected[0]!=8 and selected[0]!=4:
                # time.sleep(1)
                center=confirmation11(lettersNew)
                level_change(selected,0)
               
                
            
  



def confirmation11(currentLetters):
        global selectedBox,Pselect3,not_selected3,totalWeight1
        if selectedBox!=None:
                change_border_colour(selectedBox,0)
        selectedBox=None
        while(selectedBox==None and not stop_processing.is_set()):
            current_total=0.0
            
        
            start1=time.time()
            counter=0
            prev=None
            weights=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            weights=np.array(weights)
            for i in range(total_time3):
                
                return_value, image=camera.read()
                img = image
                img=cv2.flip(img,1)
                gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
                faces = face_cascade.detectMultiScale(gray, scaleFactor=1.3, minNeighbors=5)
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
                            selected = result

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

                if eye1!=eye2:
                    selected=None

                if selected is not None and (prev is None or prev==selected[0]):
                    weights[selected[0]]+=((i+1)/total_time3)
                    if selected[0]==4:
                        center_focus_point.config(bg="#CFF800")
                    else:
                        change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time3))
                elif selected is not None:
                    if prev==4:
                        center_focus_point.config(bg="red")
                    else:
                        change_border_colour(boxes[letters[prev]],0)
                    weights[selected[0]]+=((i+1)/total_time3)
                    if selected[0]==4:
                        center_focus_point.config(bg="#CFF800")
                    else:
                        change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time3))
                else:
                    if prev!=None:
                        if prev==4:
                            center_focus_point.config(bg="red")
                        else:
                            change_border_colour(boxes[letters[prev]],0)

                current_total+=((i+1)/total_time3)

                remaining=totalWeight1-current_total
                
                if selected is not None:
                    prev=selected[0]
                else:
                    prev=None

                remaining=totalWeight1-current_total
                if(selected is not None and  ((remaining+weights.argmax())/totalWeight1)<Threshold):
                    if selected[0]==4:
                        center_focus_point.config(bg="red")
                    else:
                        change_border_colour(boxes[letters[selected[0]]],0)
                    break
                
                counter+=1

            end1=time.time()
            # print(end1-start1,counter)
            if prev!=None:
                if prev==4:
                    center_focus_point.config(bg="red")
                else:
                    change_border_colour(boxes[letters[prev]],0)
            Max=weights.argmax()
            if(sum(weights)>0 and (weights[Max]/sum(weights))>=Threshold):
                selected=[Max]
                Pselect3.append((weights[Max]/sum(weights)))
            else:
                not_selected3+=1
                selected =None

            if selected is not None:
                selectedBox=boxes[letters[selected[0]]]
                global keystrokes,Alldata
                currentLetter=currentLetters[selected[0]]
                if currentLetter=="-":
                    currentLetter=" "
                    play_audio("space")
                elif currentLetter=='.':
                    play_audio("dot")
                elif currentLetter==',':
                    play_audio("coma")
                else:
                    play_audio(currentLetter)
                if selected[0]!=4:
                    keystrokes+=currentLetter
                
                if selected[0]!=4:
                    add_letter(keystrokes)

                if selected[0]==4:
                    center_focus_point.config(bg="red")
                else:
                    root.after(100, change_border_colour(selectedBox,0))

                # add_letter(keystrokes)
                Time=time.time()-startTime
                Alldata["Time"].append(str(round(Time,2)))
                Alldata["Frames"].append(str(total_time3))
                Alldata["Quadrant"].append(str(selected[0]))
                Alldata["letter"].append(keystrokes)
                ITRletter=math.log2(TotalLetters)*(len(keystrokes)/(Time/60))
                Alldata["ITRletter"].append(str(round(ITRletter,2)))
                ITRcommand=math.log2(TotalCommands)*(len(Alldata["Quadrant"])/(Time/60))
                Alldata["ITRcommand"].append(str(round(ITRcommand,2)))
                TER=ITRletter/math.log2(TotalLetters)
                Alldata["TER"].append(str(round(TER,2)))
                Alldata["ctime"].append(str(0))
                Alldata["meanx"].append(str(0))
                Alldata["meany"].append(str(0))
                Alldata["stdx"].append(str(0))
                Alldata["stdy"].append(str(0))
                Alldata["meanlp"].append(str(0))
                Alldata["meanrp"].append(str(0))
                Alldata["stdlp"].append(str(0))
                Alldata["stdrp"].append(str(0))
                # global detail2,detail3,detail4
                # detail2.config(text="Total Time : "+str(round(Time,2)))
                # detail3.config(text="ITR Letter: "+str(round(ITRletter,2)))
                # detail4.config(text="ITR Command: "+str(round(ITRcommand,2)))
                if selected[0]==4:
                    return True


