# !!! Use at your own risk !!!

# LiTrack Installation (Feb. 18, 2005):

# To run the GUI (Matlab v. 7.0 or higher):

- At the command prompt, type "run_LiTrack_GUI" (case insensitive, no double quotes). A color panel will appear. Click "TRACK" for a very fast demo, or double-click one of the "Save/Restore Files" and then "TRACK", to track SPPS, LCLS, or an older TESLA-XFEL, etc.

- (Optional) You can also arrange to have LiTrack start up at a simple click. After you have typed "run_LiTrack_GUI" (above) open the "Desktop" pull-down menu in the Matlab command window, choose "Command History" (if not already chosen), and note the command "run_LiTrack_GUI" appears here at the bottom of the command history list. Right-click this string and drag it up to the shortcuts bar. The Shortcut Editor window will ask for a shortcut label and an icon type (choose, for example, 'LiTrack' and 'MATLAB icon', or as you like). This shortcut will be available in future Matlab sessions as a quick LiTrack startup.

# To run the line-command version (any Matlab version?):

- At the command prompt, type "LiTrack('spps0')" (case insensitive, no double quotes). Several plots should soon appear on the screen and the tracking should finish in <1 minute (for a reasonable CPU).

A separate text file describes how to use and interpret LiTrack, but this should at least get you started.

Please E-mail Paul Emma (SLAC) at: Emma@SLAC.Stanford.edu or Marc Guetg (marcg@slac.stanford.edu), for questions or problems.

    *  To set the Matlab path:
       ======================
       Start Matlab, then in its command window, click the "File" pull-down menu, choose
       "Set Path...", and click "Add with Subfolders...", browse over to the new unzipped
       "LiTrack" folder, choose it, and then click "SAVE".

# New Features
- Allow path instead of number of wakefiles (eg element 11 col 4 can be a path)
- Added names instead of numbers as popupmenu entries

# FAQ
- If you postprocess something from LiTrack and your beamline contains cutting elements don't forget to filter the output matrixes.

