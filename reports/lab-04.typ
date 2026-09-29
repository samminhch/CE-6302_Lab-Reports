#import "@preview/subpar:0.2.2"

= Introduction
The objective of this slab was to develop a TinyML audio classification system using Edge Impulse and LaunchPad. The system was created to first collect audio data using a microphone then extract the useful parts from it an ignore the noise. Then we used the useful audio signal to train a neural classified and then test the model using the previously unseen audio. We then finally deployed the trained model back onto the LaunchPad. We were made to understand that how TinyML made it possible to perform machine learning inference directly onto a low power embedded system device rather than relying on cloud processing alone.

We had to classify the audio signal, so we converted the raw audio signal into features that were more useful for the neural network. In the Impulse Design we added learning blocks. One was a MFCC audio processing block followed by a classification (Keras) learning block. The audio processing block represented characteristics of the audio across frequency and time and allowed us to identify different sound patterns. These sound features that we processed were then supplied to the neural network which classified the audio according to its patterns.

= Procedure
We already had the required software for this lab from the previous lab (i.e. `Python`, `Node.js`, `Edge Impulse CLI`, and `TI UniFlash`). We connected an audio booster board to the LaunchPad and loaded the required firmware onto it after connecting to the computer. We used the same edge-impulse-daemon command as last lab to connect the LaunchPad to Edge Impulse. After that we started collecting audio samples of faucet and white noise using the microphone and assigned them to their classes. We collected data for 2 minutes and 50 seconds. We then used this dataset to train and evaluate the audio classification model.

In the Impulse Design section we created an impulse using MFCC processing block and a classification neural-network block. We then generated features from the audio dataset and inspected them using the Feature Explorer and then moved on to train the neural-network. We trained the model and observed that gave 100% accuracy with 0.01 loss and the confusion matrix showed 100% validation set. This helped us determine that it was effectively differentiating between the audio classes.

After that we did Live Classification with audio samples and evaluated the model onto the data which was specifically for testing. We observed and accuracy of 91.67% and now finally this trained model was now ready to be deployed onto the device as it was built correctly for the development board then flashed on the LaunchPad and then executed through the terminal to see real time classification of the audio samples on the LaunchPad.

#figure(
  image("../assets/lab04/hardware-setup.png", width: 60%),
  caption: "Edge impulse device connection for data acquisition",
)

#figure(
  image("../assets/lab04/impulse-design.png", width: 60%),
  caption: "Impulse design using the `MFCC` and `Classification` blocks",
)

#figure(
  image("../assets/lab04/feature-generation-results.png", width: 70%),
  caption: "Generated audio features displayed on the feature explorer",
)

#figure(
  image("../assets/lab04/training-performance-results.png", width: 70%),
  caption: "Neural network training performance and confusion matrix",
)

#subpar.grid(
  columns: 2,
  caption: "Live test results of our neural network model",
  figure(
    image("../assets/lab04/faucet-live-test.png"),
    caption: "Faucet noise",
  ),
  <figure:faucet-live-test>,

  figure(
    image("../assets/lab04/white-live-test.png"),
    caption: "White noise",
  ),
  <figure:white-live-test>,
)


#{
  show raw.where(block: true): it => {
    set text(size: 0.56em, fill: white)
    box(fill: black, radius: 4pt, inset: 0.5em, it)
  }
  subpar.grid(
    columns: 2,
    caption: [Terminal output of live detection with the command\ `edge-impulse-run-impulse --continuous`],
    figure(
      ```
      Timing: DSP 135ms, inference 8ms, anomaly 0ms, postprocessing 1ms
      #Classification predictions:
        faucet: 0.984736
        white: 0.015625
      Timing: DSP 135ms, inference 9ms, anomaly 0ms, postprocessing 1ms
      #Classification predictions:
        faucet: 0.996094
        white: 0.000000
      ```,
      caption: "Faucet noise",
    ),
    figure(
      ```
      Timing: DSP 135ms, inference 9ms, anomaly 0ms, postprocessing 1ms
      #Classification predictions:
        faucet: 0.007812
        white: 0.992188
      Timing: DSP 135ms, inference 9ms, anomaly 0ms, postprocessing 1ms
      #Classification predictions:
        faucet: 0.046875
        white: 0.953125
      ```,
      caption: "White noise",
    ),
  )
}

= Discussion
== Learning Blocks---MFCC Audio Processing and Classification
In the Impulse Design page we used two learning blocks the MFCC processing block and the Classification (Keras) learning block. The MFCC block processed the recorded audio and then converted it into features that represented important frequency characteristics of sound. Then we used these extracted features in the classification block where the neural network was able to learn the patterns associated with each of the audio class. Then these two blocks jointly gave us an outcome of a system that was able to transform raw audio data from the microphone into an identified and predicted audio class.

== Feature Explorer and Confusion Matrix
After we completed the first training cycle we saw that thew feature explorer was able to give us a visual representation of how the extracted features from the different classes were being separated and distributed. The confusion matrix showed us that how frequency samples from each of the classes was correct or incorrect. We observed that the accuracy results were 100% that means it was able to recognize correctly which was the faucet sound and which was the white noise sound. These results showed that the model was able to correctly identify and differentiate which classes the audio samples belonged to.

== Live Classification
Then we trained the model and tested it using classify new data where we used audio samples that were for testing not training. The accuracy was 91.67% which is pretty high accuracy considering it was very noisy in the background while feeding a new audio sample. We were able to see that the model correctly classified the sample as faucet and white noise. We were made to understand why this test was important it was because it aided in understanding how the model responded to unseen data rather than only the samples that we used for training it.

== Deployment
We then finally deployed the trained model onto the LaunchPad and tested it through the terminal. The terminal output showed us that the classification results that were being displayed were correct and that our model was running successfully on the embedded system hardware. The results showed that when we played faucet sound using a phone near the microphone it was quickly able to identify it and give us a score of 0.996094 whereas the white noise was then 0. We also observed the same thing for white noise that when we played white noise sound near the microphone, the model was able to quickly recognize it and give us a white noise score of 0.99218 and the faucet value came close to 0. These results confirmed that the complete TinyML workflow was working correctly, from data acquisition to feature extraction to classification to the on-device inference, everything was implemented successfully. Therefore, the output that we saw showed us that the trained model could do audio classification directly on the LaunchPad.

== Conclusion
In conclusion we used Edge Impulse and LaunchPad to create a TinyML audio classification system. This lab emphasized on what the major stages of embedded machine learning applications are and how to correctly perform data acquisition, feature extraction, neural-network training, model evaluation and deployment for maximum accuracy results for audio classification. We successfully met all the lab objectives and took screenshots accordingly.

#pagebreak()
= Appendix I---Use of Large Language Models
#import "@preview/cheq:0.4.0": checklist
#show: checklist
#table(
  align: top,
  stroke: none,
  inset: (left: 0pt, right: 1em),
  columns: 3,
  [*Was an LLM used for this project?*], [- [ ] Yes], [- [x] No],
)

= Appendix II---Edge Impulse Machine Learning Model
We did not have any source code for this lab. We created the machine learning model using Edge Impulse where we trained, tested and deployed it onto the provided CC1352P firmware.
