### WhatsApp chat analysis with R
This script is designed to perform a detailed analysis of WhatsApp chats. It visualizes the total number of text messages, pictures, videos, etc. sent and identifies which participant has sent the most of each type. To utilize this script, simply export your WhatsApp chat and run the provided R code.

*Important Note*: This script is specifically developed for analyzing WhatsApp chats in **German**. If you intend to use it for chats in any other language, you may need to make some modifications:
- **Text-specific Markers**: The code identifies certain text patterns like "Ende-zu-Ende-verschlüsselt" or "Bild weggelassen", which differ in other languages.
- **Date and Time Formats**: The script assumes a specific format for date and time stamps, which can vary based on language and regional settings.
- **Regular Expressions**: If the script uses regular expressions (Regex) to recognize language-specific patterns, these will need to be adjusted for use in other languages.

Therefore, before applying this script to your exported WhatsApp chat, please check and adjust these aspects as necessary. A careful review and modification are essential to ensure accurate and meaningful analysis results.













