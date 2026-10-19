class ParsedPaymentMessage {
  final double amount;
  final String defaultType; // 'expense' or 'income'
  final String source;
  final String merchant;
  final String suggestedCategory;
  final String rawText;

  ParsedPaymentMessage({
    required this.amount,
    required this.defaultType,
    required this.source,
    required this.merchant,
    required this.suggestedCategory,
    required this.rawText,
  });
}

class SmsParserService {
  static ParsedPaymentMessage? parse(String rawText) {
    if (rawText.trim().isEmpty) return null;
    final text = rawText.trim();

    // 1. Extract Amount
    double? amount;
    final amtMatch1 =
        RegExp(r'(?:rs\.?|inr|₹)\s*([\d,]+(?:\.\d{1,2})?)', caseSensitive: false)
            .firstMatch(text);
    final amtMatch2 =
        RegExp(r'([\d,]+(?:\.\d{1,2})?)\s*(?:rs\.?|inr|₹)', caseSensitive: false)
            .firstMatch(text);
    final amtMatch3 = RegExp(
            r'(?:debited|credited|spent|paid|received)\s+(?:by|for|with)?\s*([\d,]+(?:\.\d{1,2})?)',
            caseSensitive: false)
        .firstMatch(text);

    if (amtMatch1 != null) {
      amount = double.tryParse(amtMatch1.group(1)!.replaceAll(',', ''));
    } else if (amtMatch2 != null) {
      amount = double.tryParse(amtMatch2.group(1)!.replaceAll(',', ''));
    } else if (amtMatch3 != null) {
      amount = double.tryParse(amtMatch3.group(1)!.replaceAll(',', ''));
    }

    if (amount == null || amount <= 0) return null;

    // 2. Detect Debit vs Credit on user's account
    // If account was debited, it's an expense; if account was credited, it's income
    bool isDebit = false;
    bool isCredit = false;

    if (RegExp(r'(?:acct|a/c|card|account)?\s*[\w*]*\s*debited|debited\s+(?:for|by|with)', caseSensitive: false).hasMatch(text)) {
      isDebit = true;
    } else if (RegExp(r'(?:acct|a/c|card|account)?\s*[\w*]*\s*credited|credited\s+(?:for|by|with)', caseSensitive: false).hasMatch(text)) {
      isCredit = true;
    } else if (RegExp(r'spent|paid|purchase|sent to', caseSensitive: false).hasMatch(text)) {
      isDebit = true;
    } else if (RegExp(r'received|deposited|refund|cashback', caseSensitive: false).hasMatch(text)) {
      isCredit = true;
    }

    final defaultType = isCredit ? 'income' : 'expense';

    // 3. Detect Source Platform / Bank
    String source = 'Bank SMS';
    if (RegExp(r'google\s*pay|gpay|okaxis|okhdfcbank|oksbi|okicici',
            caseSensitive: false)
        .hasMatch(text)) {
      source = 'Google Pay (GPay)';
    } else if (RegExp(r'phonepe|ybl|axl|ibl', caseSensitive: false)
        .hasMatch(text)) {
      source = 'PhonePe';
    } else if (RegExp(r'paytm', caseSensitive: false).hasMatch(text)) {
      source = 'Paytm UPI';
    } else if (RegExp(r'hdfc', caseSensitive: false).hasMatch(text)) {
      source = 'HDFC Bank';
    } else if (RegExp(r'sbi|state\s*bank', caseSensitive: false).hasMatch(text)) {
      source = 'State Bank of India';
    } else if (RegExp(r'icici', caseSensitive: false).hasMatch(text)) {
      source = 'ICICI Bank';
    } else if (RegExp(r'axis', caseSensitive: false).hasMatch(text)) {
      source = 'Axis Bank';
    }

    // 4. Extract Merchant / Beneficiary
    String merchant = 'Online / Merchant';

    // Pattern: "; MOHD JAVED credited"
    final recipientMatch = RegExp(r';\s*([A-Za-z\s]+?)\s+credited', caseSensitive: false).firstMatch(text);
    final toMatch = RegExp(
            r'(?:to\s+(?:VPA\s+)?|at\s+|info:\s*|from\s+)([\w\s@\.\-]+?)(?:\s+on|\s+ref|\s+upi|\s+avl|\.|$)',
            caseSensitive: false)
        .firstMatch(text);

    if (recipientMatch != null && recipientMatch.group(1) != null) {
      merchant = recipientMatch.group(1)!.trim();
    } else if (toMatch != null && toMatch.group(1) != null) {
      merchant = toMatch.group(1)!.trim().replaceAll(RegExp(r'^(the|a)\s+', caseSensitive: false), '');
    }

    // 5. Intelligent Category Suggestion
    String suggestedCategory = defaultType == 'income' ? 'salary' : 'food';
    final lower = text.toLowerCase();
    if (RegExp(r'swiggy|zomato|eats|mcdonald|kfc|starbucks|pizza|burger|cafe|hotel|restaurant|food')
        .hasMatch(lower)) {
      suggestedCategory = 'food';
    } else if (RegExp(r'uber|ola|rapido|metro|petrol|diesel|fuel|shell|indian\s*oil|bpcl|hpcl|auto|cab|flight|railway|irctc')
        .hasMatch(lower)) {
      suggestedCategory = 'transport';
    } else if (RegExp(r'blinkit|zepto|instamart|dmart|bigbasket|nature|supermarket|grocery|milk|provisions')
        .hasMatch(lower)) {
      suggestedCategory = 'groceries';
    } else if (RegExp(r'amazon|flipkart|myntra|ajio|meesho|zara|h&m|decathlon|retail|shopping')
        .hasMatch(lower)) {
      suggestedCategory = 'shopping';
    } else if (RegExp(r'airtel|jio|vi|bescom|tneb|electricity|broadband|wifi|bill|recharge|dth')
        .hasMatch(lower)) {
      suggestedCategory = 'bills';
    } else if (RegExp(r'movie|pvr|inox|netflix|spotify|prime|hotstar|cinema|game')
        .hasMatch(lower)) {
      suggestedCategory = 'entertainment';
    } else if (RegExp(r'apollo|pharmeasy|netmeds|medplus|clinic|hospital|doctor|pharmacy')
        .hasMatch(lower)) {
      suggestedCategory = 'health';
    } else if (RegExp(r'salary|bonus|interest|dividend|stipend').hasMatch(lower)) {
      suggestedCategory = 'salary';
    }

    return ParsedPaymentMessage(
      amount: amount,
      defaultType: defaultType,
      source: source,
      merchant: merchant,
      suggestedCategory: suggestedCategory,
      rawText: rawText,
    );
  }
}
