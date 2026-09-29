#import "@preview/subpar:0.2.2"

= Introduction
This lab helped us build and understand how continuous motion recognition works
and how we can use TinyML on the LaunchPad. We were made to collect several
gestures using the accelerometer, then process it in Edge Impulse and then train
the neural network classifier to identify each gesture separately. The trained
impulse was then tested with new motion data and then it was deployed back to
the Launchpad so that it ran it locally using inference.

We were made to understand how TinyML combined machine learning with embedded
systems. The data that was sampled using the accelerometer and the frequency was
set to 62.5Hz. The four motion classifications were Idle, Snake, Wave and
Uptown. Edge Impulse was instructed to divide the data into raw time-series data
windows, then extract the spectral features, feed those features into a
classifier. Then perform spectral analysis because repetitive motion produced a
characteristic frequency domain which was displaying spectral power patterns and
this helped in identifying the four gestures.

The final embedded model that we were asked to make performed inference on the
LaunchPad and did not require constant cloud processing. The main aim of this
lab was to demonstrate the main advantage of edge machine learning that how we
can use sensor data to be processed right where it is generated and that helped
in reducing communication requirements and allowing super low latency operation.
The lab instructions were to collect datasets of 8 minutes and 35 seconds of
motion data and then show that the final validation accuracy was 95.5%.

= Procedure
We attached the BoosterPack to the LaunchPad and connected it to our computer. The software requirement was to install `Python`, `Node.js`, `Edge Impulse CLI` and `TI UniFlash` which we did prior to coming to the lab. The `Edge Impulse CLI` was installed using the manual instructions through `npm` and then the `UniFlash` installation directory was added to the Windows path send then finally we flashed the Edge Impulse firmware to the board and used the edge-impulse-daemon to login and selected our Edge Impulse project.

After the device was successfully connected we then collected the accelerometer samples in the data acquisition page. We collected 8 minutes and 35 seconds of motion data with four motion gestures: `idle`, `wave`, `snake`, `uczpdown`. We collected 10 samples for training set and 14 samples for test set which gave us a data split of 78% / 22%, shown on @figure:edge-impulse-data-summary.~We then finally used this data to create the TinyML impulse and trained the classifier.

We created an impulse design and added the blocks for time series data with frequency $62.5"Hz"$ and training 100% of the dataset. We then performed spectral analysis after adding that block. We added a classification block which is mainly what was classifying our data and then we added an anomaly detection block which was basically to detect if there was a motion happening outside of the four categories that we had defined. We finally trained the model, tested it and deployed it back to the device for live classification then took screenshots of the terminal while our model was running to show that our classification was happening accurately and that the anomaly score was positive.

#figure(
  image("../assets/lab03/edge-impulse-data-summary.png", width: 60%),
  caption: [Edge Impulse data acquisition showing accelerometer samples for four
    motion classes],
)<figure:edge-impulse-data-summary>

#figure(
  image("../assets/lab03/impulse-design-blocks.png", width: 50%),
  caption: [Creating impulse design and adding learning blocks],
)<figure:impulse-design-blocks>

#subpar.grid(
  columns: 1,
  caption: [Edge Impulse spectral analysis raw data, DSP result, and spectral
    power log.],
  figure(image("../assets/lab03/spectral-raw-data.png", width: 80%)),
  figure(image("../assets/lab03/spectral-dsp-filter.png", width: 60%)),
)<figure:spectral-processing>

#figure(
  image("../assets/lab03/classifier-accuracy.png", width: 60%),
  caption: [Edge impulse classifier accuracy],
)<figure:classifier-accuracy>

#subpar.grid(
  columns: 2,
  align: center + horizon,
  caption: [Data explorer for `updown` motion],
  figure(image("../assets/lab03/data-sample-updown.png")),
  figure(image("../assets/lab03/data-explorer-updown.png")),
)<figure:data-explorer-updown>

#figure(
  image("../assets/lab03/anomaly-detection-explorer.png", width: 50%),
  caption: [Edge impulse anomaly detection explorer],
)<figure:anomaly-detection-explorer>

#figure(
  image("../assets/lab03/classifier-anomaly-accuracy.png", width: 60%),
  caption: [Edge impulse model testing results],
)<figure:classifier-anomaly-accuracy>

#figure(
  image("../assets/lab03/model-optimization-performance.png", width: 70%),
  caption: [Edge impulse model optimization and performance],
)<figure:model-optimization-performance>

#figure(
  image("../assets/lab03/training-set-feature-explorer.png"),
  caption: [Edge impulse training set and feature explorer],
)

#subpar.grid(
  columns: 2,
  caption: [Example on-device predictions for `idle`, `snake`, `updown`, and
    `wave` motions],
  figure(image("../assets/lab03/terminal-idle-out.png")),
  figure(image("../assets/lab03/terminal-snake-out.png")),

  figure(image("../assets/lab03/terminal-updown-out.png")),
  figure(image("../assets/lab03/terminal-wave-out.png")),
)<figure:terminal-out-classes>

#subpar.grid(
  columns: 2,
  caption: [Terminal output while the deployed motion recognition model is
    running on the LaunchPad],
  figure(image("../assets/lab03/terminal-out-1.png")),
  figure(image("../assets/lab03/terminal-out-2.png")),
)<figure:terminal-out>

= Discussion
== Impulse Design and Spectral Analysis
We were able to observe that Edge Impulse was dividing the continuous signal into smaller windows before the extraction and the Spectral Analysis block that we were asked to apply was filtering and converting the motion data into features that the classifier could easily learn from. The output of Spectral Analysis was filtered signal, frequency-domain information and spectral power. This made us notice that similar gestures were actually producing similar feature patterns even though each time we sampled the data it was not the same but at least similar. So after saving the spectral parameters we generated features for all windows in the dataset and the Feature Explorer was able to show us a visual representation of the extracted features and better separation of the four motions showed that the classifier had more distinctive information available for learning.

== Impulse Classification
We then understood how the Classification block worked and that was basically a neural network that was extracting spectral features and putting them into the four categories: `idle`, `snake`, `wave` and `updown`.

== Neural Network Training Performance
We saw that the neural network was trained using the spectral features that we had generated using the Spectral Analysis block using the labeled accelerometer recordings of data. The first training cycle we performed was evaluated using both the reported accuracy and the confusion matrix. This gave us an idea that how often the true class of the gesture was being predicted (i.e. if it was accurately being predicted as `idle`, `snake`, `wave` or `updown`). This made it possible to closely observe and identify which of the gestures were overlapping or being confused amongst themselves. We used the default neural-network parameters to see if training was happening accurately and above 80%. Thankfully, as shown in @figure:classifier-accuracy, our model gave us an accuracy of 95.5% and a loss of 0.11 so we did not have to retrain our model. The confusion matrix gave us 100% correct classification for Snake and Wave, 93.3% for `updown` and 88.5% for `idle`. The main confusion that occurred in our model was between `idle` and `updown` which was about 11.5% and 6.7%. This means that 11.5% of idle windows were classified as `updown` and 6.7% of `updown` windows were classified as `idle`. This helped us understand that the four motions were generally well separated but there was a slight overlap happening between `idle` and `updown`.

== Live Classification and Deployment
We trained the model and tested the motion data using Live Classification before we deployed it. We used a sample length of $5000"ms"$ for this test as instructed in the manual. We successfully interpreted why we did this step and that was because good performance on the training data alone does not really guarantee that the model will generalize the movements that it has not previously seen so that’s why we need successful Live Classification results to assign a correct category to the highest probability resembling gesture. This meant that the probability of other classes was low and that gesture was resembling that one specific class.

The result of this Live Classification was that it could identify the four motion classes successfully and we got 100% accuracy with the value 1 for ROC area and 0.96 for weighted precision, weighted recall, and weighted F1 score.

== Anomaly Detection
We added this block to help identify a motion which is not familiar or does not resemble any of the four classes that we have already defined. The K means anomaly model group that is known for training data into clusters in the feature space. We observed in the Anomaly explorer that there were several cluster regions that were being formed and they were being formed. The X-Axis was `accX RMS`, the Y-Axis was `accY RMS` and any new sample that was not in these regions was assigned a larger anomaly score. This basically meant that the classifier was seeing an unfamiliar motion that it had not seen before.

== Deployment and On-Device Output
After we successfully trained and tested the impulse we deployed it to the LaunchPad. We did so by using the Edge Impulse Deployment page and then flashed it back on the LaunchPad. The deployment basically consisted of the signal processing code, the neural-network weights and the classification code which was the complete impulse that can be executed on the embedded system. We observed that once we were able to successfully deploy everything the inference was able to run even without a continuous internet connection and this basically reduced latency and communication overhead.

We were able to note that the deployed model produced a continuous classification stream with scores for each classification in the terminal. We saw that if the device was idle it gave us a score of `idle = 0.906259` and the rest of the classes closer to `0`. Similarly when we did a Snake motion it showed `snake = 0.996094` and rest `0` and for `updown` motion it gave `updown = 0.949219` and rest `0` and finally for Wave motion it gave `wave = 0.996094` and the rest of the emotions were `0`. We also observed the DP processing value in the terminal which was $68"ms"$. For inference we saw it was 1ms and for anomaly processing it was 0-1ms.

These results showed that our model was running successfully on the LaunchPad and that it was correctly recognizing all the motion classes.

#pagebreak()
== Conclusion
In conclusion this lab emphasized on how complete TinyML workflow happens for continuous motion recognition. We were able to understand how to successfully collect labeled accelerometer data then extract spectral features then train and validate it using a neural-network classifier and then add an anomaly detection block for any motion outside of the classes and then finally we deployed the model onto the LaunchPad. We collected data for 8 minutes and 35 seconds with a data split of 78% / 22% between training and testing. The trained model was able to achieve 95.5% validation accuracy and the separate model testing results showed 100% accuracy. We were able to get correct terminal output results too which proved on-device recognition of the four motion gestures, `idle`, `snake`, `wave`, and `updown`. In conclusion the purpose of this lab was to help make us familiar with how TinyML can perform motion classification locally on a low
power embedded system platform.

#pagebreak()
= Appendix I---Use of Large Language Models
#import "@preview/cheq:0.4.0": checklist
#show: checklist

#table(
  columns: 3,
  stroke: none,
  align: top,
  [*Was an LLM used for this project?*], [- [ ] Yes], [- [x] No],
)

= Appendix II---Edge Impulse Machine Learning Model
There was no source code for this lab. We created the machine learning model using Edge Impulse where we
