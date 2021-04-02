# Pós-presença

 A Flutter application for PPGC-like programs to help in the students attendence management. 

Summary
------------
- [Introduction](#introduction)
- [Installation](#installation)
- [Implemented functionalities and features](#implemented-functionalities-and-features)
- [Partially implemented functionalities and features](#partially-implemented-functionalities-and-features)
- [Lacking (and planned) functionalities and features](#lacking)
- [Usability test protocols and tasks](#usability-test-protocols-and-tasks)
- [Results and statistical analysis ](#results-and-statistical-analysis)


Introduction
------------
Pós-presença is an automated solution designed for PPGC and PGMICRO graduate programs of Federal University of Rio Grande do Sul, which currently manage their student's attendence through manually counting their pen-made signatures each week, considerably slowing down the administration workflow. The application was developed as the final project of the Interação Homem-Computador (Human-Computer Interaction) UFRGS's Computer Science course and proposed two methods for that: QR Code presence registration; and PIN Code presence registration. 

Usability testing protocols were planned and performed with real users, making it possible to run a rigorous statistical analysis that investigated interface problems and helped validate some design decisions, as well as reconsider others. 

Because of the functionallity urgence and its conceptual simplicity, vertical implementations were prioritized over horizontal ones. Hence, consolidating more backend features (including a database solution) and leaving aside some styling/aesthetic aspects. 

Installation
------------
Due to the incompleteness of our Flutter application, there's no official apk or ipa available, so you may test its functionality by cloning this repository, installing the third-party packages and finally building it. Since we still haven't tested Pós-presença on iOS platform, the bellow installion steps covers only Android users.

    git clone https://github.com/colombelli/pos-presenca.git
    cd pos-presenca
    flutter clean
    flutter pub get
    flutter build apk
    
The generated apk file will be available in ``pg-check/build/app/outputs/apk/app.apk``
    
Implemented functionalities and features
------------
* E-mail/password login and registration :white_check_mark:
* Absences status calendar :white_check_mark:
* QR Code scan for presence registration :white_check_mark:
* QR Code dynamical generation for presence validation :white_check_mark:
  * Double QR Code logic for further interaction robustness :white_check_mark:
  * Cloud validation to improve security :white_check_mark:
* PIN Code dynamical generation for presence validation (on pinInterface branch) :white_check_mark:
  * Double PIN Code logic for further interaction robustness :white_check_mark:
* Student justification request when above allowed week absences :white_check_mark:
* Student-side text justification for absences (week-oriented) :white_check_mark:
* Administration-side justification approval/disapproval :white_check_mark:
* Professor-side (student's advisor) screen with student's attendence information :white_check_mark:

Partially implemented functionalities and features
------------
* Double language application (en-US / pt-BR)
* Cross-platform application (Android / iOS)

<a name="lacking">Lacking (and planned) functionalities and features</a>
------------
* Administration-side presence registration lock-screen
* Periodical cloud function for updating student's attendence situation
* Firebase security deployment for safer database communication

Usability test protocols and tasks
------------
In order to formally compare how well the solution improved the original task (and if it really did), as well as for comparing our two possible implementations, we chose two scenarios for simulating the administrative workflow both with and without our solution, in addition to two scenarios for registering the student's presence. The performance of the tasks were assessed by the NASA-TLX method regarding their workload, and by the SUS method regarding the application's usability.  

Administrative scenarios:
1. Manual absences processing with the aid of a spreadsheet with basic students' information: the participants should go through a list of 25 imaginary students checking if their simulated signature was present on each day of the week and also correctly notify (with a standardized e-mail message) the ones that were over the allowed number of weekly absences.
2. Absences processing through the application: the participants should log in the application with the administrative account, access the weekly absences area and notify the ones listed there.

Students scenarios:
1. Presence registration with QR code solution: log in the application with student's credentials; navigate to the presence registration page; click in the button to open up the camera; point the camera at the device showing the current valid QR code; wait for the confirmatio messagen; close the confirmation message.
2. Presence registration with PIN code solution: log in the application with student's credentials; navigate to the presence registration page; identify generated personal PIN code ontheir user device; type the PIN code at the administration device asking for it; wait for the confirmation message; close the confirmation message.


Results and statistical analysis 
------------
Normalizing all the SUS test answers the obtained mean is approximately equals to 75 with a standard deviation of 6.51. The score 75 is above the studied average of 68 and is greater than 70% of the interfaces of the same study. According to the proposed segmentation, this value corresponds to a grade **B+**. 

The NASA-TLX results were statistically tested. For all hypothesis, we generated the kernel density and boxplots for the selected data, probed them with a normality test using the Shapiro-Wilk method and when both the groups were considered having a normal distribution, we applied the Welch t-test for assessing if there was any statistically significant difference among them. In the case of non-parametric data, we chose to apply a Wilcoxon signed-rank test. All the performed analysis considered the tradional p-value of 0.05.

* H0: There is no difference in the difficulty of processing absences between using the application solution and using the original manual workflow.
  * **Rejected**
  * x̄(App) < x̄(Manual)
  * Interpretation: using the app is easier

* H0: There is no difference regarding the mental effort for processing absences between using the application solution and using the original manual workflow. 
  * **Rejected**
  * x̄(App) < x̄(Manual)
  * Interpretation: using the app takes less mental effort

* H0: There is no difference in the difficulty of registering presence between using the QR code and the PIN code methods. 
  * **Rejected**
  * x̄(QR) < x̄(PIN)
  * Interpretation: the QR code method is easier to use


* H0: There is no difference in the time taken to register presence between using the QR code and the PIN code methods.
  * **Rejected**
  * x̄(QR) < x̄(PIN)
  * Interpretation: the PIN method task takes longer

The following plots correspond to the above tested hypothesis. The textual informations are in portuguese since the course was taken in Brazil.

<p float="left">
  <img src="/analysis/plots/Quão difícil foi a tarefaAPPMAN.png" width="400" />
  <img src="/analysis/plots//Quanta demanda mental foi necessáriaAPPMAN.png" width="400" /> 
</p>

<p float="left">
  <img src="/analysis/plots/Quão difícil foi a tarefaQRPIN.png" width="400" />
  <img src="/analysis/plots/Quanto tempo durou a tarefaQRPIN.png" width="400" /> 
</p>


