
class GlossaryTerm {
  final String plainEnglish;
  final String cutTheCrap;
  const GlossaryTerm({required this.plainEnglish, required this.cutTheCrap});
}

const Map<String, GlossaryTerm> termGlossary = {
  'index fund': GlossaryTerm(
    plainEnglish: 'A basket that holds a tiny slice of every company in the market at once.',
    cutTheCrap:
        'The finance industry spent decades making this sound complicated. It isn\'t. Buy the whole market, pay almost nothing in fees, leave it alone. That\'s it.',
  ),
  'ETF': GlossaryTerm(
    plainEnglish: 'A basket of investments you buy like a single share.',
    cutTheCrap:
        'Same idea as an index fund – just bought on the stock exchange. Lower fees than almost anything else out there.',
  ),
  'index': GlossaryTerm(
    plainEnglish: 'A list of companies used to measure how a market is performing.',
    cutTheCrap:
        'The ASX 200 is just a list of the 200 biggest Australian companies. When people say the market went up, they mean this list went up.',
  ),
  'compound interest': GlossaryTerm(
    plainEnglish: 'Your money making money on the money it already made.',
    cutTheCrap: 'A snowball rolling downhill. Starts tiny. Gets enormous. The hill is time. The only mistake is not starting.',
  ),
  'compound growth': GlossaryTerm(
    plainEnglish: 'Your returns earning returns on your returns.',
    cutTheCrap: 'A snowball rolling downhill. Starts tiny. Gets enormous. The hill is time. The only mistake is not starting.',
  ),
  'inflation': GlossaryTerm(
    plainEnglish: 'The slow shrinking of what your dollar can buy.',
    cutTheCrap:
        'Your savings account balance stays the same. What it can actually buy quietly shrinks every year. The bank doesn\'t mention this.',
  ),
  'purchasing power': GlossaryTerm(
    plainEnglish: 'What your money can actually buy.',
    cutTheCrap: '\$100 in 1971 had more purchasing power than \$100 today. The number is the same. The reality behind it isn\'t.',
  ),
  'interest rate': GlossaryTerm(
    plainEnglish: 'The price of borrowing money – or the reward for lending it.',
    cutTheCrap:
        'When the bank lends you money you pay interest. When you lend the bank your savings they pay you interest. The bank always tries to make the first number bigger and the second number smaller. Now you know.',
  ),
  'superannuation': GlossaryTerm(
    plainEnglish: 'Your future self\'s savings account – that your employer fills, and you can\'t touch until you\'re 60.',
    cutTheCrap: 'It\'s yours. It\'s just in a vault with a very long lock timer. Most women have no idea what\'s in it. That\'s exactly what this lesson is about.',
  ),
  'share': GlossaryTerm(
    plainEnglish: 'A small piece of ownership in a company.',
    cutTheCrap: 'If Apple were a pie, a share is one slice. If Apple does well your slice gets more valuable. You own a real piece of a real business.',
  ),
  'dividend': GlossaryTerm(
    plainEnglish: 'A company sharing some of its profits with the people who own its shares.',
    cutTheCrap: 'You own a slice of the business. The business makes money. Some of that money gets sent to you. No meetings required.',
  ),
  'asset': GlossaryTerm(
    plainEnglish: 'Anything you own that holds or grows in value.',
    cutTheCrap: 'Your super, your property, your shares, your gold. Not your car – that one shrinks the moment you drive it off the lot.',
  ),
  'liability': GlossaryTerm(
    plainEnglish: 'Anything you owe.',
    cutTheCrap: 'The mortgage, the credit card, the buy-now-pay-later. The opposite of an asset. Most people have a clearer picture of their liabilities than their assets. Flip that.',
  ),
  'net worth': GlossaryTerm(
    plainEnglish: 'Everything you own minus everything you owe.',
    cutTheCrap: 'The only number that actually tells you where you stand. Not your salary. Not your savings balance. Everything you own minus everything you owe.',
  ),
  'mortgage': GlossaryTerm(
    plainEnglish: 'A loan specifically for buying property, where the property itself is the security.',
    cutTheCrap: 'The bank lends you the money to buy the house. If you stop paying, they get the house. So you keep paying. The interest is the cost of using their money to build your asset.',
  ),
  'equity': GlossaryTerm(
    plainEnglish: 'The portion of an asset you actually own – after subtracting what you owe on it.',
    cutTheCrap: 'Home worth \$800,000. Mortgage \$500,000. Your equity is \$300,000. That\'s the part that\'s actually yours.',
  ),
  'capital gains': GlossaryTerm(
    plainEnglish: 'The profit you make when you sell an asset for more than you paid.',
    cutTheCrap: 'Buy shares at \$10. Sell at \$15. The \$5 is a capital gain. The ATO will want a conversation about it. Worth having.',
  ),
  'diversification': GlossaryTerm(
    plainEnglish: 'Not putting all your eggs in one basket.',
    cutTheCrap: 'If one investment fails, the others cushion the fall. The index fund is the most elegant version of this.',
  ),
  'liquidity': GlossaryTerm(
    plainEnglish: 'How quickly you can turn an asset into cash.',
    cutTheCrap: 'Your savings account: liquid. Your property: not liquid. You cannot sell a bedroom to pay an urgent bill.',
  ),
  'portfolio': GlossaryTerm(
    plainEnglish: 'The collection of all your investments viewed together as one picture.',
    cutTheCrap: 'Not just your shares. Your super, your ETFs, your property, your savings. All of it together is your portfolio.',
  ),
  'risk tolerance': GlossaryTerm(
    plainEnglish: 'How much uncertainty you can sit with without making a panicked decision.',
    cutTheCrap: 'Not about being brave. About knowing yourself well enough to build a strategy you\'ll actually stick to.',
  ),
  'tax deduction': GlossaryTerm(
    plainEnglish: 'An expense that reduces the amount of income you\'re taxed on.',
    cutTheCrap: 'You spent \$300 on work supplies. The ATO says: fine, we\'ll only tax you as if you earned \$300 less. Not a refund. A reduction. Keep the receipts.',
  ),
  'franking credits': GlossaryTerm(
    plainEnglish: 'A tax credit that stops you being taxed twice on the same company profit.',
    cutTheCrap: 'The company paid tax before passing profits to you. The franking credit proves it – so the ATO doesn\'t tax you again. Uniquely Australian. Genuinely useful.',
  ),
  'offset account': GlossaryTerm(
    plainEnglish: 'A savings account linked to your mortgage – every dollar in it reduces the interest you pay.',
    cutTheCrap: '\$300,000 mortgage. \$50,000 in your offset. You only pay interest on \$250,000. No investment risk. Just interest you quietly don\'t pay.',
  ),
  'income protection': GlossaryTerm(
    plainEnglish: 'Insurance that replaces a portion of your salary if you can\'t work due to illness or injury.',
    cutTheCrap: 'Not life insurance. Specifically: your body stops working, this keeps money coming in. Most Australian women have it inside their super and have never read the policy.',
  ),
  'TPD': GlossaryTerm(
    plainEnglish: 'Insurance that pays a lump sum if you\'re permanently unable to work.',
    cutTheCrap: 'One payment, not ongoing income. Often sitting inside your super right now. Check the Insurance section of your super fund.',
  ),
  'beneficiary': GlossaryTerm(
    plainEnglish: 'The person nominated to receive your super or insurance payout if you die.',
    cutTheCrap: 'The most important form most people have never updated since their first job. If you nominated an ex-partner – fix it this week.',
  ),
  'fiat currency': GlossaryTerm(
    plainEnglish: 'Money that\'s valuable because everyone agrees it is – not because it\'s backed by anything physical.',
    cutTheCrap: 'Since 1971 your money has been backed by nothing except the government\'s promise. Governments have a habit of printing more of it.',
  ),
  'stock to flow': GlossaryTerm(
    plainEnglish: 'A measure of scarcity – how much of something exists versus how much is being produced.',
    cutTheCrap: 'Gold has a high ratio because it\'s hard to mine more of it. Bitcoin\'s is even higher – and unlike gold, it\'s fixed by code.',
  ),
  'CPI': GlossaryTerm(
    plainEnglish: 'The official measure of inflation – tracks how much a standard basket of goods costs over time.',
    cutTheCrap: 'If that basket cost \$100 last year and \$103 this year, CPI is 3%. That\'s the Inflation Thief\'s official job title.',
  ),
  'monetary policy': GlossaryTerm(
    plainEnglish: 'How the Reserve Bank manages interest rates to influence the economy.',
    cutTheCrap: 'The RBA has one main lever: interest rates. Raise them to slow spending. Lower them to encourage borrowing. Every mortgage rate change in Australia traces back to this decision.',
  ),
  'voluntary contributions': GlossaryTerm(
    plainEnglish: 'Extra money you choose to put into your super on top of what your employer contributes.',
    cutTheCrap: 'Your employer puts in 11.5%. You can add more. Even \$25 a fortnight compounds into a significant difference over 20 years.',
  ),
  'store of value': GlossaryTerm(
    plainEnglish: 'An asset that holds its worth over time without deteriorating.',
    cutTheCrap: 'Gold holds its value. Cash in a drawer loses purchasing power every year. The difference is whether the thing you\'re holding keeps up with – or beats – inflation.',
  ),
  'medium of exchange': GlossaryTerm(
    plainEnglish: 'Something widely accepted as payment for goods and services.',
    cutTheCrap: 'The reason you can buy coffee with dollars but not with gold bars. Convenience and universal acceptance is what makes something a medium of exchange.',
  ),
  'unit of account': GlossaryTerm(
    plainEnglish: 'A standard measure used to price goods and compare value.',
    cutTheCrap: 'You know a coffee costs \$5 and a car costs \$30,000 because we price everything in the same unit. Without this, trade would be chaos.',
  ),
};
