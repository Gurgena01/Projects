import os

def process_voice_message(file_path: str, max_size_mb: float = 5.0) -> dict:
    if not os.path.exists(file_path):
        return {"status": "error", "message": "ფაილი ვერ მოიძებნა"}

    file_size_mb = os.path.getsize(file_path) / (1024 * 1024)
    if file_size_mb > max_size_mb:
        return {"status": "rejected", "reason": "ფაილის ზომა აჭარბებს ლიმიტს"}

    ext = os.path.splitext(file_path)[1].lower()
    if ext not in ['.wav', '.mp3', '.m4a']:
        return {"status": "rejected", "reason": f"არასწორი ფორმატი: {ext}"}

    transcript = "გამარჯობა, მაინტერესებს ჩემი ბარათის მოქმედების ვადა."
    
    return {
        "status": "success",
        "file_name": os.path.basename(file_path),
        "transcript": transcript,
        "word_count": len(transcript.split())
    }


if __name__ == "__main__":
    res = process_voice_message("sample_user_voice.wav")
    print(res)