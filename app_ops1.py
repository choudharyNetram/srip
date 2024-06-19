from flask import Flask, request, jsonify
import numpy as np
import cv2
import base64

app = Flask(__name__)

@app.route('/upload-yuv', methods=['POST'])
def upload_yuv():
    try:
        yuv_data = request.form['yuv_data']
        # Decode base64 if needed
        yuv_bytes = base64.b64decode(yuv_data)

        # Example: Convert YUV data to image (using OpenCV)
        # Replace with your actual YUV to image conversion
        width = 640
        height = 480
        image = yuv_to_image(yuv_bytes, width, height)

        # Process the image (save, analyze, etc.)
        # Example: Save image
        cv2.imwrite('uploaded_image.jpg', image)

        return jsonify({'message': 'YUV data processed successfully'}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

def yuv_to_image(yuv_bytes, width, height):
    # Example: Dummy conversion, replace with actual YUV to image conversion
    # Here, assume YUV is directly converted to RGB using OpenCV
    yuv_np = np.frombuffer(yuv_bytes, dtype=np.uint8)
    yuv_np = yuv_np.reshape((int(height * 1.5), width))
    image = cv2.cvtColor(yuv_np, cv2.COLOR_YUV2BGR_I420)  # Adjust color conversion as per your YUV format
    return image

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)



""" lettersNew=""
keystrokes=""
selectedBox=None
Threshold=0.6



Threshold1=6
givenText=None
total_time=10
dwell_time=1.5
TotalCommands=9
TotalLetters=56
d=(2/total_time)-(1/total_time)
a=(1/total_time)
n=total_time
totalWeight=(n)/(2*(2*a+(n-1)*d))




def process_image():
    global selectedBox,camera
    selectedBox=None
    center=False
    while not stop_processing.is_set():
        current_total=0.0
        global detail2_ans
        global letters,root

        # if not center:
        #     data=str(text1.get("1.0","end-1c"))
        #     # data1=str(text2.get("1.0","end-1c"))
        #     text1.delete('1.0',tk.END)
        #     text1.insert(tk.END,data)
        #     # text2.delete('1.0',tk.END)
        #     # text2.insert(tk.END,data1)
        #     center=False
        
        # data=str(text1.get("1.0","end-1c"))
        # data1=str(text2.get("1.0","end-1c"))
        # text1.delete('1.0',tk.END)
        # text1.insert(tk.END,data)
        # text2.delete('1.0',tk.END)
        # text2.insert(tk.END,data1)


        # if selectedBox!=None:
        #     root.after(10, change_border_colour(selectedBox,0))

        counter=0
        prev=None
        weights=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
        weights=np.array(weights)
        start1=time.time()

        for i in range(total_time):
            
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

            if selected is not None and selected[0]==4:
                selected=None
            
            if selected is not None and (prev is None or prev==selected[0]):
                print("first")
                weights[selected[0]]+=((i+1)/total_time)
                change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time))
            elif selected is not None:
                print("second")
                change_border_colour(boxes[letters[prev]],0)
                weights[selected[0]]+=((i+1)/total_time)
                change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time))
            else:
                print("third")
                if prev!=None:
                    change_border_colour(boxes[letters[prev]],0)

            current_total+=((i+1)/total_time)

            remaining=totalWeight-current_total

            if(selected is not None and ((remaining+weights.argmax())/totalWeight)<Threshold):
                print("fourth")
                change_border_colour(boxes[letters[selected[0]]],0)
                break

            if selected is not None:
                prev=selected[0]
            else:
                prev=None
            
            counter+=1
        
        end1=time.time()
        print(end1-start1)
        if prev!=None:
            change_border_colour(boxes[letters[prev]],0)

        Max=weights.argmax()
        if(sum(weights)>0 and (weights[Max]/sum(weights))>=Threshold):
            selected=[Max]
        else :
            selected =None

        if selected is not None:
            selectedBox=boxes[letters[selected[0]]]
            if prev!=4:
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
            Alldata["Frames"].append(str(total_time))
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
                center=confirmation(lettersNew)
                level_change(selected,0) 
               




def confirmation(currentLetters):
        global selectedBox,camera
        if selectedBox!=None:
                change_border_colour(selectedBox,0)
        selectedBox=None

        # data=str(text1.get("1.0","end-1c"))
        # # # data1=str(text2.get("1.0","end-1c"))
        # text1.delete('1.0',tk.END)
        # text1.insert(tk.END,data)
        # text1.config(bg="white")
        # text1.config(width=40, height=4)
        # text2.config(width=40,height=4)
        # center_focus_point.config(padx=10,pady=0)

        # data=str(text1.get("1.0","end-1c"))
        # # data1=str(text2.get("1.0","end-1c"))
        # text1.delete('1.0',tk.END)
        # text1.insert(tk.END,data)
        # text1.config(bg="white")
        # text1.config(width=40, height=4)
        # text2.config(width=40,height=4)
        # center_focus_point.config(padx=10,pady=0)
        
        while(selectedBox==None and not stop_processing.is_set()) :
            current_total=0.0
                   

            start1=time.time()
            counter=0
            prev=None
            weights=[0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
            weights=np.array(weights)     
            for i in range(total_time):
                
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
                            # selected = result
                            eye1=result

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
                    weights[selected[0]]+=((i+1)/total_time)
                    if selected[0]==4:
                        center_focus_point.config(bg="#CFF800")
                    else:
                        change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time))
                elif selected is not None:
                    if prev==4:
                        center_focus_point.config(bg="red")
                    else:
                        change_border_colour(boxes[letters[prev]],0)
                    weights[selected[0]]+=((i+1)/total_time)
                    if selected[0]==4:
                        center_focus_point.config(bg="#CFF800")
                    else:
                        change_border_colour(boxes[letters[selected[0]]],((i+1)/total_time))
                else:
                    if prev!=None:
                        if prev==4:
                            center_focus_point.config(bg="red")
                        else:
                            change_border_colour(boxes[letters[prev]],0)

                current_total+=((i+1)/total_time)

                remaining=totalWeight-current_total

                if(selected is not None and ((remaining+weights.argmax())/totalWeight)<Threshold):
                    if selected[0]==4:
                        center_focus_point.config(bg="red")
                    else:
                        change_border_colour(boxes[letters[selected[0]]],0)
                    break
                
                if selected is not None:
                    prev=selected[0]
                else:
                    prev=None
                

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
            else :
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
                    
                # add_letter(keystrokes)
                if selected[0]==4:
                    center_focus_point.config(bg="red")
                else:
                    root.after(100, change_border_colour(selectedBox,0))
                
                Time=time.time()-startTime
                Alldata["Time"].append(str(round(Time,2)))
                Alldata["Frames"].append(str(total_time))
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


                    """ 