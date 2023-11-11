### WhatsApp Chat Analysis with R
This comprehensive R script is designed to analyze WhatsApp chat histories. It provides insights into communication patterns by visualizing the number and types of messages sent, including text messages, pictures, videos, and more, and identifies the most active participants in the chat.

*Key Features*:
- **Message Type Analysis**: Visualizes the distribution of different types of messages (text, picture, audio, etc.) sent by each participant.
- **Daily Message Trends**: Plots the number of messages sent per day, providing insights into chat activity over time.
- **Monthly Analysis**: Examines the number of messages and characters sent per month, offering a detailed view of communication patterns.
- **Statistical Testing**: Includes Wilcoxon tests to compare message counts and characters between participants on a monthly basis.
- **Customizable Visualizations**: Features a variety of plots (line plots, bar charts, box plots) with customizable color schemes for easy interpretation.

*Instructions*:
1. **Export WhatsApp Chat**: Export your WhatsApp chat into a '.txt' file and place it in an accessible directory.
2. **Adapt File Path**: Modify the file path in the script to point to your exported chat file.
3. **Run the Script**: Execute the script in R to analyze the chat data and generate visualization.
4. **Interpret Results**: View the plots and statistics to gain insights into chat dynamics and participant engagement.

*Important Notes*:
- **Language Specifity**: This script is tailored for WhatsApp chats in **German**. Adjustments might be necessary for chats in other languages, particularly regarding text markers, date/time formats, and regular expressions.
- **Libraries**: This script utilizes **'stringr'**, **'tidyverse'**, **'lubridate'**, **'cowplot'**, **'rstatix'**, and **'ggpubr'** for data processing and visualization. Ensure these are installed and up-to-date.














