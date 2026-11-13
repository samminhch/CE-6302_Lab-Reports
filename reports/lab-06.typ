#import "@preview/unify:0.8.1": num, numrange, qty, unit
#import "@preview/subpar:0.2.2"
#import "common.typ"

#common.title[Lab 06---Signal Classification using Spectral Features (Part 1)]

= Introduction
The main objective of part 1 this lab was to help us understand how to classify signals using spectral features and deep neural network (DNN) using Edge Impulse and large dataset from Hugging face. This dataset was comprised of filtered and segmented ECG recordings from 290 individuals, and we had to examine how frequency features and neural network settings were classifying them. There was a problem with Edge Impulse interface while classifying 290 classes, it trained the model but the accuracy, loss and confusion matrix information was not getting displayed in the classification section so we filtered the data and disables values from 175 to 300 and trained our model for that.

We basically focused on extracting the spectral features from the dataset and training the DNN while understanding how limitations of spectral features for ECG classification work.

= Procedure<section:part1:procedure>
We first uploaded the ECG dataset@yogeswar_reddy_thota_2025, separating the training and testing data. Next, we filtered the samples by label to use samples #numrange(0, 175) to reduce the number of active classes used for classification (Edge Impulse crashes with too many classes). A screenshot of the dataset is shown in @figure:part1:data-acquisition.

#figure(
  box(
    clip: true,
    height: 30%,
    inset: (bottom: -4in),
    image("../assets/lab06/1_data-acquisition.png", width: 100%, fit: "cover"),
  ),
  caption: [Data acquisition in Edge Impulse],
)<figure:part1:data-acquisition>

For the impulse, we added the "Spectral Analysis" processing block for the data, which can be seen in @figure:part1:impulse. In the spectral features, we scale axes and input decimation ratio to #num(1.0), the type to `none`, in the filter section, and setting the type in analysis section to `FFT` with a length of #num(16). Additionally, the we checked the boxes of taking $log$ of the spectrum and overlapping the FFT frames, which can be seen in @figure:part1:spectral-feature-params. After saving these parameters according to the manual we generated features and checked the box for calculating feature importance. After generating these features, we saw that the feature importance (@figure:part1:spectral-feature-importance) showed ECG spectral skewness, signal kurtosis, signal RMS, signal skewness, signal spectral kurtosis and signal spectral power for different frequencies which are basically all the features that are used to classify everything.

We then trained the model in the classifier section and set the dense layers to 60 neurons, and we used two of them. We trained for 30 training cycles and set the learning rate to #num(0.0005). We were able to get an accuracy of #qty(48.4, "%") with 2.03 loss after the model finished training.

Finally, we went to the deployment section and set the device to ESP-EYE (ESP32) and built the model to fill out the flash values for quantization (`int8`) table and un-optimized (`float32`) flash values in the table. We took screenshots of everything and recorded the video explaining the process describing in detail how deep neural network works and how it was helpful in training our model.

#figure(
  image("../assets/lab06/1_impulse.png", width: 80%),
  caption: [Impulse creation for spectral analysis],
)<figure:part1:impulse>

#figure(
  image("../assets/lab06/1_spectral-features-parameters.png", width: 80%),
  caption: [Spectral feature parameters],
)<figure:part1:spectral-feature-params>

#figure(
  image("../assets/lab06/1_spectral-features.png", width: 80%),
  caption: [Spectral features with the "Feature Importance" table],
)<figure:part1:spectral-feature-importance>

#figure(
  image("../assets/lab06/1_training-performance-output.png", width: 80%),
  caption: [DNN training performance and training output],
)<figure:part1:training-performance>

= Discussion
With the help of this lab we understand how Spectral Analysis works in Edge Impulse. Spectral Analysis is basically a compact representation of the ECG recordings by summarizing their frequency characteristics. The information that we got from feature importance helped us identify which extracted features were contributing to differentiate between the active classes. The filter we used to keep labels #numrange(0, 174) helped to reduce the classification task to a much more smaller set of individual classes. We understood that if we trained the full dataset, we would get a little less accuracy than what we got for less of it.

We used two dense layers of 60 neurons to train the deep neural network DNN. This gave us a better idea of how the data was being trained using multiple layers of interconnected nodes and how the spectral features and individual labels we being classified. We were able to get an accuracy of #qty(48.4, "%") with 2.03 loss.

We basically became familiar with the fact that what are the limitations of spectral analysis, and it only summarizes frequency content without fully preserving when the change occurs in the ECG segment. Therefore, the recordings from different individuals had some similar spectral features despite having a different waveform timing. This was the main limitation of using spectral analysis for classification.

== Conclusion
In conclusion, this part demonstrated how to extract an ECG dataset from HuggingFace and then extract its spectral features using spectral analysis and then finally train a deep neural network DNN in Edge Impulse. We disabled labels #numrange(175, 300) and used two dense layers of 60 neurons each and trained our model for 30 training cycles with a learning rate of #num(0.0005). Hence this lab showed the usefulness of frequency features for classification and the importance of evaluating what kind of limitations they posses and whether they are capable of correctly distinguishing the individual classes.

#pagebreak()
#counter(heading).update(0)
#common.title[Lab 06---Signal Classification using Spectrogram\ (Part 2)]

= Introduction
The object of this part of the  lab is to classify the ECG recordings from the dataset using spectrogram features. We compared the classifications using DNN with two dense layers of 60 neurons, and CNN with 1D and 2D architectures. We used the same dataset as in the previous part.

The design impulse had spectrogram and classification learning blocks, and the spectrogram represented how the frequency content of the signal was changing over time. We were able to see that unlike spectral summaries, with the spectrogram we were actually able to see how the information was being preserved about the timing of frequency changes within each ECG segment. We understood how these features supported classification and how the model accuracy was more as compared to spectral analysis.

= Procedure
We just created another impulse with spectrogram and classification learning blocks and set the spectrogram parameters to 0.02 frame length, 0.01 frame stride and 128 FFT length and we set the noise floor in dB to -52. After saving these parameters we generated features. We then classified first using the deep neural network by adding two dense layers of 60 neurons each which gave us an accuracy of #qty(95.1, "%") with 0.28 loss. We then went to the deployment section and built the model for target device ESP-EYE to get flash values for the table of quantization (`int8`) and un-optimized (`float32`).

We then trained the model for CNN 1D convolution architecture by adding layers of reshape layer of 65 columns, `1D conv/ pool layer` (8 filters, 3 kernel size, 1 layer) and another `1D conv/ pool layer` (16 filters, 3 kernel size, 1 layer) and two layers of dropout rate of 0.25. This gave us an accuracy of #qty(97.2, "%") with 0.23 loss. We did the same thing by flashing the device in the deployment section.

Finally we trained the model for CNN 2D convolution architecture by using the layers reshape layer of 65 columns, `2D conv/ pool layer` (8 filters, 3kernel size, 1 layer) and another `2D conv/ pool layer` (16 filters, 3 kernel size, 1 layer) and two layers of dropout rate of 0.25. This gave us an accuracy of #qty(97.8, "%") with 0.18 loss. We did the same thing to fill out the table in the deployment section by building and flashing the device.

#figure(
  image("../assets/lab06/2_spectrogram-parameters.png"),
  caption: [Spectrogram parameters],
)<figure:part2:spectrogram-parameters>

#figure(
  image("../assets/lab06/2_spectrogram-features.png"),
  caption: [Spectrogram Feature Generation],
)


#subpar.grid(
  columns: 2,
  align: bottom,
  figure(
    image("../assets/lab-06/DNN-training-output.png"),
    caption: [Training performance and training output],
  ),
  figure(
    image("../assets/lab-06/DNN-deployment-flash-table.png"),
    caption: [Flash values table],
  ),

  caption: [
    DNN performance and flash values table
  ],
)

#subpar.grid(
  columns: 2,
  align: bottom,
  figure(
    image("../assets/lab-06/CNN1D-training-output.png"),
    caption: [Training performance and training output],
  ),
  figure(
    image("../assets/lab-06/CNN1D-deployment-flash-table.png"),
    caption: [Flash values table],
  ),
)

#subpar.grid(
  columns: 2,
  align: bottom,
  figure(
    image("../assets/lab-06/CNN2D-training-output.png"),
    caption: [Training performance and training output],
  ),
  figure(
    image("../assets/lab-06/CNN2D-deployment-flash-table.png"),
    caption: [Flash values table],
  ),
)

#figure(
  table(
    columns: (..(auto,) * 9,),
    align: (x, y) => if y < 4 and x > 0 { center } else { left } + horizon,
    table.header(
      [*Features*],
      table.cell(colspan: 2)[Spectral],
      table.cell(colspan: 6)[Spectrogram],
      [*Model*],
      table.cell(colspan: 2)[DNN ($2 times 60$)],
      table.cell(colspan: 2)[DNN ($2 times 60$)],
      table.cell(colspan: 2)[CNN (1D)],
      table.cell(colspan: 2)[CNN (2D)],
      [*Training Cycles*],
      table.cell(colspan: 2)[30],
      table.cell(colspan: 6)[10],
      [*Data Type*], ..(`int`, `float`) * 4,
      table.cell(fill: luma(80%), colspan: 9)[],
    ),
    [Latency (#unit("ms"))],
    num(75),
    num(78),
    num(161),
    num(331),
    num(175),
    num(371),
    num(574),
    num(3.367),

    [RAM (#unit("KiB"))],
    num(4.6),
    num(4.6),
    num(26.6),
    num(26.6),
    num(26.6),
    num(52.5),
    num(26.6),
    num(26.6),

    [Flash (#unit("KiB"))],
    num(29.6),
    num(69.8),
    num(405.9),
    num(1500),
    num(100.2),
    num(303.7),
    num(1200),
    num(4600),

    [Accuracy (#unit("%"))],
    num(36.14),
    num(50.38),
    num(92.01),
    num(92.55),
    num(95.79),
    num(95.75),
    num(97.49),
    num(97.44),
  ),
  caption: [A table showing the performance metrics of the different models built.],
)<figure:performance-table>

= Discussion
We observed how different spectrogram features gave both frequency content and provided its variation overtime and how the different DNN and CNN 1D and 2D convolution models gave different ESP-EYE (ESP32) deployment estimates that we used to compare the inference latency, RAM and flash of the different models and make and fill out the table. In spectrogram we saw that the overlapping frames helped to maintain the continuity between the adjacent portions of the ECG recordings. The FFT length that we set to 128 was used to determine the frequency resolution and the noise floor normalization parameter which was set to -52dB was used to control the low-power components.

The Deep Neural Network DNN that we used had two dense layers of 60 neurons each and we trained it for 10 cycles with a learning rate of 0.0005. It learning relationships across the generated spectrogram features and gave us an accuracy of #qty(95.1, "%") with 0.28 loss.

The Convolutional Neural Network CNN that we used with 1D convolution architecture gave us an accuracy of #qty(97.2, "%") with 0.23 loss.

The Convolutional Neural Network CNN that we used with 2D convolution architecture gave us an accuracy of #qty(97.8, "%") with 0.18 loss. We observed how these different architectures gave us different ways of learning local patterns from the features generated in the spectrogram. We then compared all these models’ performances by creating a table with accuracy, latency, RAM and Flash of each model.

We understood that how in TinyML the most suitable model is actually the one with the most acceptable accuracy and must have a good memory and processing limits. So basically, the `int8` quantization can reduce the memory requirements and inference time but the accuracy should be checked against the `float32` un-optimized model. Based on our results we saw that CNN 1D convolution architecture gave us the best balance of accuracy, latency and resource utilization.

== Conclusion
In conclusion, we were made familiar with how ECG classification works using spectrogram learning block. We saw different classification models with DNN, 1D CNN and 2D CNN architectures. We compared each of the classifications using a table which showed us that why accuracy alone is not sufficient to select a model for an embedded device. The model that we ended up preferring the most was `int8` 1D CNN is the best overall TinyML choice: #qty(95.79, "%") accuracy, #qty(175, "ms") latency, and #qty(100.2, "kiB") flash. The `int8` 2D CNN has the highest accuracy at #qty(97.49, "%"), but takes #qty(574, "ms") and #qty(1.2, "MiB") flash based on its classification performance and the ESP32 resource requirements.

We also understood the difference between CNN and DNN thoroughly that how DNN used fully connected layers to learn relationships among input features, while the CNNs used convolutional filters to learn local patterns in the spectrogram.
#pagebreak()
#bibliography(title: "References", style: "ieee", "../references.yaml")

= Appendix I---Use of Large Language Models
#table(
  stroke: none,
  inset: (left: 0pt, right: 1em),
  columns: 3,
  [Was an LLM used for this project?],
  [#sym.square.stroked.big Yes],
  [#sym.ballot.check No],
)

= Appendix II---Edge Impulse Machine Learning Model
We did not have any source code for this lab. We created the machine learning model using a dataset from HugggingFace on Edge Impulse where we trained and tested it.
