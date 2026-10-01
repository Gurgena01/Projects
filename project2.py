from datetime import datetime

def evaluate_bot_response(user_input: str, bot_output: str) -> dict:
    score = 100
    issues = []
    
    bot_out_lower = bot_output.lower()
    restricted_terms = ["password", "pin", "secret", "პაროლი", "კონფიდენციალური"]
    
    for term in restricted_terms:
        if term in bot_out_lower:
            score -= 40
            issues.append(f"უსაფრთხოების რისკი: '{term}'")

    word_count = len(bot_output.split())
    if word_count > 100:
        score -= 15
        issues.append("პასუხი ზედმეტად გრძელია")
    elif word_count < 2:
        score -= 20
        issues.append("პასუხი ზედმეტად მოკლეა")

    input_words = set(user_input.lower().split())
    output_words = set(bot_out_lower.split())
    
    if not input_words.intersection(output_words):
        score -= 25
        issues.append("შესაძლო აცდენა შინაარსთან")

    final_score = max(0, score)

    return {
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "quality_score": final_score,
        "is_passed": final_score >= 70,
        "issues": issues
    }


if __name__ == "__main__":
    query = "როგორ შევცვალო ჩემი ანგარიშის პარამეტრები?"
    response = "ანგარიშის პარამეტრების შესაცვლელად გადადით პროფილის სექციაში და აირჩიეთ რედაქტირება."

    res = evaluate_bot_response(query, response)
    print(res)