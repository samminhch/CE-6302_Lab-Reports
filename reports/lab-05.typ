#import "common.typ"

#common.title[Lab 05---Image Classification (Part 1)])

= Introduction
The objective of part 1 of this lab was to help us understand how to configure the ESP-EYE development board and make a connection between that board and Edge Impulse for the purpose of image classification. We understood that ESP-EYE is based on the ESP32 microcontroller processor and it had a camera that we used to collect images. We then used these images to execute TinyML model for classification that which image is which object. We were made familiar with how Edge Impulse was used to build a model starting from data acquisition then adding learning block and training the model to what we wanted it to do and then final deployment back onto the board.

= Procedure
Firstly, we downloaded the drivers that were required for the ESP-EYE. As instructed in the manual, we installed the Silicon Labs CP210x USB-to-UART driver so that the ESP-EYE could be connected to the computer’s serial interface. After the ESP-EYE was connected to COM15 we opened Edge Impulse and selected the ESP32 device in there with 240 MHz Then we acquired data of one pig plushie, a wallet and empty space. The pig-plushie was bright colors like pink, yellow, light blue and the wallet was black which gave us a good contrast for image classification. We created an impulse and added the image and transfer learning block and trained our model by selecting RGB for the color depth in parameters section. We generated features and trained the data and got 100% accuracy with 0.15 loss. We then tested the model with for live classification and then finally deployed the model back onto the device. We took screenshots of the terminal in which we showed it clearly classifying the image as pig plushie when the camera was pointed on it with a value of 0.996094 and wallet and empty values 0. Similarly, when we pointed the camera to the wallet the terminal window showed wallet value as 0.996094 and pig plushie and empty 0. Finally when we pointed on the table the empty value was 0.996094 and pig plushie and wallet values were 0.

#figure(
  image("../assets/lab05/part1-impulse-design.png", width: 70%),
  caption: [Impulse design using image and transfer learning blocks],
)<figure:part1-impulse-design>

#figure(
  image("../assets/lab05/part1-feature-explorer.png", width: 70%),
  caption: [Feature explorer and training set],
)<figure:part1-feature-explorer>

#figure(
  image("../assets/lab05/part1-nn-training.png", width: 80%),
  caption: [Neural network training performance and output],
)

#figure(
  image("../assets/lab05/part1-live-classification-pig.png"),
  caption: [Live classification results of pig plushie],
)

#figure(
  image("../assets/lab05/part1-live-classification-wallet.png"),
  caption: [Live classification results of wallet image],
)

#figure(
  image("../assets/lab05/part1-live-classification-empty.png"),
  caption: [Live classification results of empty image],
)

#figure(
  image("../assets/lab05/part1-terminal-output-pig.png", width: 60%),
  caption: [Live terminal output showing deployed model displaying matches for pig plushie],
)

#figure(
  image("../assets/lab05/part1-terminal-output-wallet.png", width: 60%),
  caption: [Live terminal output showing deployed model displaying matches for wallet],
)

#figure(
  image("../assets/lab05/part1-terminal-output-empty.png", width: 75%),
  caption: [Live terminal output showing deployed model displaying matches for empty background],
)

= Discussion
The image classification model was running successfully and was able to determine the difference between the pig plushie, wallet and empty. We understood how the bright colors of the pig plushie compared with the dark colors of the wallet gave us a really good contrast and our model was able to distinguish between the classes. We were able to successfully generate the features and get an accuracy of 100% with 0.15 loss. The live classification we did for model testing also showed that the model was able to correctly recognize between the classes. We also observed that after the deployment of this model back onto the device it was able to determine which class the object we placed in front of the camera was with classification value of 0.996094 for the correct class and 0 for the other two classes. The results showed that the model was successfully trained to distinguish between objects based on image classification on the ESP-EYE.

== Conclusion
In conclusion the main objective of part 1 of this lab was to help us develop and deploy an image classification model on the ESP-EYE. We collected data for 3 different classes, pig plushie, wallet and empty which were contrasting colors. We processed these and used them to train the transfer learning model in Edge Impulse. We got a training accuracy of 100% and even in live classification it was able to identify the pig plushie, wallet and empty objects correctly and place them in their respective classes. The final deployment on the device also gave us correct classification of the objects based on when the camera was pointed towards them. Therefore, the lab emphasized on how we can collect image data, train it in embedded machine learning for image classification and then perform real-time image classification of the ESP-EYE.

#pagebreak()
#counter(heading).update(0)
#common.title[Lab 05---Image Classification (Part 2)]

= Introduction
The objective of part 2 of this lab was to develop an image classification model on a much larger dataset from Hugging face. We used the Beans dataset to classify the leaves into three categories as angular leaf spot, bean rust and healthy. We imported this dataset onto Edge Impulse in the data acquisition section with training and testing data separately with a 89%/11% dataset split. After that we used the same image and transfer learning block to train the model for classification.

= Procedure
First we downloaded `git`, `git-lfs`, and the `beans` dataset from Hugging Face as instructed in the manual. We observed that the dataset already contained separate files for the training and testing of data. We uploaded those images onto Edge impulse with labels, angular leaf spot, bean rust and healthy for both training ans well and testing. After creating the impulse we generated the features. We trained the model using MobileNetV2 96×96 0.35, with 120 training epochs, a 10% validation set, and a learning rate of 0.0005. After training the model and getting a performance accuracy percentage of 74.0%, we tested it using the testing dataset by selecting classify all under model testing. After that we got an accuracy of 70.93%.

Through trial and error, we tweaked the model to have the final settings of 120 cycles, learning rate of 0.005, validation set size of 20%, and a batch size of 2048. Unfortunately were not able to get better testing performance compared to the original values, not matter what values we changed.

#figure(
  image(
    "../assets/lab05/part2-initial-training-performance-result.png",
    width: 80%,
  ),
  caption: [Neural network training performance of the initial settings],
)

#figure(
  image(
    "../assets/lab05/part2-initial-model-testing-performance.png",
    width: 80%,
  ),
  caption: [Neural network testing performance with the initial settings],
)

#figure(
  image(
    "../assets/lab05/part2-other-model-training-performance-result.png",
    width: 80%,
  ),
  caption: [Neural network training performance while tweaking some settings. We scrapped these adjustments after finding an incredibly low model testing accuracy percentage.],
)

#figure(
  image(
    "../assets/lab05/part2-final-training-performance-result.png",
    width: 80%,
  ),
  caption: [Neural network training performance of the final settings],
)

#figure(
  image(
    "../assets/lab05/part2-final-model-testing-performance.png",
    width: 80%,
  ),
  caption: [Neural network testing performance of the final settings],
)

= Discussion
We observed that the model was able to correctly distinguish the image features for angular leaf spot, bean rust and healthy classes. The feature explorer was able to show us the distribution of the three classes and the confusion matrix gave us a more detailed view of the correct and incorrect classifications. We saw a slight overlap in the confusion matrix because different leaf diseases contained similar visual characteristics so the model was not able to categorize them but overall, we got an accuracy of 74.0%. So, this part of the lab helped us understand how transfer learning was used for a large dataset to categorize different diseases classification for leaves. We set the training cycles to 130, a learning rate of 0.0005, data augmentation, and a validation set size of 10%, which gave us an accuracy of 76.8%, but an incredibly low testing percentage rate. Finally, we set the learning rate to 0.005 with no data augmentation and 20% validation set size with a batch size of 2048, and it gave us an accuracy of 76.8%. Unfortunately we were not able to match the testing accuracy of the default settings despite the training performance accuracy being higher.


== Conclusion
In conclusion part 2 of this lab emphasized on the process of using publicly available Hugging Face dataset top create and evaluate an image classification model in Edge Impulse. We uploaded the Beans dataset in Edge Impulse and then trained it using a transfer learning model so that it was able to correctly classify all three categories angular leaf spot, bean rust and healthy and we did that for both training and then tested the model too using the testing dataset. Therefore, the lab showed how TinyML and transfer learning can be used for a large public dataset on Hugging Face for plant disease image classification.

#pagebreak()
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
== Part 1
We did not have any source code for this lab. We created the machine learning model using Edge Impulse where we trained, tested and deployed it onto the provided ESP-EYE firmware.

== Part 2
We did not have any source code for this lab. We created the machine learning model using Edge Impulse where we trained, and tested with the provided Beans dataset from Hugging Face
