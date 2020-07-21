# Pós-presença

 A Flutter application for PPGC-like programs to help in the students attendence management. 

Introduction
------------
Pós-presença is an automated solution for UFRGS's PPGC and PGMICRO graduate programs, which currently manages its student's attendence through manually counting their pen-made signature absences each week, considerably slowing down the workflow. The application was developed as the final project of the Interação Homem-Computador (Man-Machine Interaction) UFRGS's Computer Science dsicipline and proposed two methods for that: QR Code presence registration, and PIN Code presence registration. 

User testing protocols were planned and performed, making possible to run a rigorous statistical analysis that searched for interface problems and helped validate some design decisions, as well as reconsider others. 

Because of the functionallity urgence and its conceptual simplicity, vertical implementations were prioritized over horizontal ones. Hence, consolidating more backend features (including a database solution) and leaving aside some styling aspects. 

Instalation
------------
Because of the incompleteness of our Flutter application, there's no apk available, so you may test its functionality by cloning this repository, installing the used packages and finally building its apk (we still didn't tested it on iOS platform).

    git clone https://github.com/colombelli/pg-check.git
    cd pg-check
    flutter clean
    flutter pub get
    flutter build apk
    
The apk file will be available in ``pg-check/build/app/outputs/apk/app.apk``
    
Implemented functionalities and features
------------
* E-mail/password login and registration :white_check_mark:
* Absences status calendar :white_check_mark:
* QR Code scan for presence registration
* QR Code dynamical generation for presence validation :white_check_mark:
  * Double QR Code logic for further interaction robustness :white_check_mark:
  * Cloud validation to improve security :white_check_mark:
* PIN Code dynamical generation for presence validation (on pinInterface branch) :white_check_mark:
  * Double PIN Code logic for further interaction robustness :white_check_mark:
* Student justification request when above allowed week absences :white_check_mark:
* Student-side text justification for absences (week-based) :white_check_mark:
* Administration-side justification approval/disapproval :white_check_mark:
* Professor-side (student's advisor) screen with student's attendence information :white_check_mark:

Partially implemented functionalities and features
------------
* Double language application (en-US / pt-BR)
* Cross-platform application (Android / iOS)

Planned absent functionalities and features
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
