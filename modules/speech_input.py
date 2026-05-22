import speech_recognition as sr

def get_voice_command():

    recognizer = sr.Recognizer()

    with sr.Microphone() as source:

        print("Listening for destination...")

        recognizer.adjust_for_ambient_noise(source)

        audio = recognizer.listen(source)

    try:

        text = recognizer.recognize_google(audio)

        text = text.strip().title()

        print("You said:", text)

        return text

    except Exception as e:

        print(e)

        return None