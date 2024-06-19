import tensorflow as tf

import tensorflow as tf

# Load the SavedModel
saved_model_dir = './saved_model_1/saved_model_1'
model = tf.saved_model.load(saved_model_dir)

# Print input and output details
concrete_func = model.signatures['serving_default']
inputs = concrete_func.inputs
outputs = concrete_func.outputs

print("Model Inputs:")
for input_tensor in inputs:
    print(f"Name: {input_tensor.name}, Shape: {input_tensor.shape}, Type: {input_tensor.dtype}")

print("\nModel Outputs:")
for output_tensor in outputs:
    print(f"Name: {output_tensor.name}, Shape: {output_tensor.shape}, Type: {output_tensor.dtype}")

# Convert the model to TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_saved_model(saved_model_dir)
tflite_model = converter.convert()

# Save the TFLite model
tflite_model_path = 'model.tflite'
with open(tflite_model_path, 'wb') as f:
    f.write(tflite_model)

print(f"\nTFLite model saved to {tflite_model_path}")

# Convert the model
""" 
converter = tf.lite.TFLiteConverter.from_saved_model('./saved_model_1/saved_model_1') # path to the SavedModel directory
tflite_model = converter.convert()

# Save the model.
with open('model.tflite', 'wb') as f:
  f.write(tflite_model)


# Convert the model.
converter = tf.lite.TFLiteConverter.from_keras_model('./saved_model_1/saved_model_1/keras_metadata.pb')
tflite_model = converter.convert()

# Save the model.
with open('model.tflite_keras', 'wb') as f:
  f.write(tflite_model)

  """ 
