# Pós-presença

 A Flutter application for PPGC-like programs to help in the students attendence management. 

Introduction
------------
Pós-presença is an automated solution designed for PPGC and PGMICRO graduate programs of Federal University of Rio Grande do Sul, which currently manage their student's attendence through manually counting their pen-made signatures each week, considerably slowing down the administration workflow. The application was developed as the final project of the Interação Homem-Computador (Man-Machine Interaction) UFRGS's Computer Science discipline and proposed two methods for that: QR Code presence registration; and PIN Code presence registration. 

Usability testing protocols were planned and performed with real users, making it possible to run a rigorous statistical analysis that investigated interface problems and helped validate some design decisions, as well as reconsider others. 

Because of the functionallity urgence and its conceptual simplicity, vertical implementations were prioritized over horizontal ones. Hence, consolidating more backend features (including a database solution) and leaving aside some styling/aesthetic aspects. 

Installation
------------
Due to the incompleteness of our Flutter application, there's no official apk or ipa available, so you may test its functionality by cloning this repository, installing the third-party packages and finally building it. Since we still haven't tested Pós-presença on iOS platform, the bellow installion steps covers only Android users.

    git clone https://github.com/colombelli/pg-check.git
    cd pg-check
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

Lacking (and planned) functionalities and features
------------
* Administration-side presence registration lock-screen
* Periodical cloud function for updating student's attendence situation
* Firebase security deployment for safer database communication

Screenshots
------------

Usability test protocols
------------

Statistical analysis
------------
