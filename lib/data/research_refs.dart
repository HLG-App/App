class ResearchRef {
  final String refId;
  final String source;
  final String year;
  final String plainSummary;
  final String url;

  const ResearchRef({
    required this.refId,
    required this.source,
    required this.year,
    required this.plainSummary,
    required this.url,
  });
}

const Map<String, ResearchRef> researchRefs = {
  'women_financial_literacy': ResearchRef(
    refId: 'women_financial_literacy',
    source: 'OECD Financial Literacy Survey',
    year: '2020',
    plainSummary: 'The OECD surveyed adults across 26 countries. Women consistently showed lower financial literacy scores – not because of ability, but because of access and education gaps.',
    url: 'https://oecd.org/finance/financial-education',
  ),
  'women_confidence_gap': ResearchRef(
    refId: 'women_confidence_gap',
    source: 'Management Science – Bucher-Koenen et al.',
    year: '2021',
    plainSummary: 'Researchers found that 30% of the measured financial knowledge gap between men and women is explained by confidence, not actual knowledge. Women often select "I don\'t know" even when they know the right answer.',
    url: 'https://pubsonline.informs.org',
  ),
  'women_invest_outperform': ResearchRef(
    refId: 'women_invest_outperform',
    source: 'Fidelity Investments',
    year: '2021',
    plainSummary: 'Fidelity analysed 5.2 million investment accounts. Women outperformed men by 0.4% per year on average – largely because they traded less and held their investments longer.',
    url: 'https://www.fidelity.com/learning-center/trading-investing/women-and-investing',
  ),
  'australia_house_prices': ResearchRef(
    refId: 'australia_house_prices',
    source: 'Reserve Bank of Australia – Long-run Housing Data',
    year: '2023',
    plainSummary: 'RBA data shows the ratio of median dwelling prices to average household income has more than tripled since the early 1970s – from roughly 3x to 10–13x average income.',
    url: 'https://rba.gov.au/statistics',
  ),
  'rba_inflation_calculator': ResearchRef(
    refId: 'rba_inflation_calculator',
    source: 'Reserve Bank of Australia – Inflation Calculator',
    year: '2024',
    plainSummary: 'The RBA\'s own inflation calculator shows that \$100 in 1971 has the equivalent purchasing power of approximately \$8–10 today. A 90%+ loss of purchasing power in one lifetime.',
    url: 'https://rba.gov.au/calculator',
  ),
  'madam_cj_walker': ResearchRef(
    refId: 'madam_cj_walker',
    source: 'On Her Own Ground – A\'Lelia Bundles',
    year: '2001',
    plainSummary: 'Thoroughly documented biography of Madam C.J. Walker by her great-great-granddaughter, a journalist and historian. Walker is documented as the first self-made female millionaire in American history.',
    url: 'https://aleliabundles.com',
  ),
  'australia_cpi': ResearchRef(
    refId: 'australia_cpi',
    source: 'Australian Bureau of Statistics – CPI All Groups',
    year: '2024',
    plainSummary: 'The ABS tracks the Consumer Price Index quarterly. Australia\'s long-run average inflation since the early 1990s sits around 2.5–3% annually.',
    url: 'https://abs.gov.au/statistics/economy/price-indexes-and-inflation',
  ),
  'gender_pay_gap_wgea': ResearchRef(
    refId: 'gender_pay_gap_wgea',
    source: 'Workplace Gender Equality Agency – Gender Pay Gap Report',
    year: '2024',
    plainSummary: 'WGEA publishes annual pay gap data by industry and occupation. The national average for full-time workers sits at approximately 17% – meaning women earn 83 cents for every dollar men earn.',
    url: 'https://wgea.gov.au/data-statistics/gender-pay-gap-data',
  ),
  'super_gap_asfa': ResearchRef(
    refId: 'super_gap_asfa',
    source: 'Association of Superannuation Funds of Australia',
    year: '2023',
    plainSummary: 'ASFA research consistently shows women retire with approximately 47% less superannuation than men – driven by the pay gap, career breaks, and part-time work patterns.',
    url: 'https://superannuation.asn.au/resources/retirement-standard',
  ),
  'motherhood_penalty': ResearchRef(
    refId: 'motherhood_penalty',
    source: 'Melbourne Institute – Household Income and Labour Dynamics in Australia',
    year: '2022',
    plainSummary: 'Having children is associated with a wage penalty for women and a wage premium for men across most developed economies. The Melbourne Institute\'s HILDA survey confirms this pattern in Australia.',
    url: 'https://melbourneinstitute.unimelb.edu.au',
  ),
  'spiva_active_funds': ResearchRef(
    refId: 'spiva_active_funds',
    source: 'S&P SPIVA Australia Scorecard',
    year: '2023',
    plainSummary: 'S&P Dow Jones publishes the SPIVA scorecard annually for Australia. Consistently shows 70–90% of actively managed funds underperform their benchmark index over 10-year periods.',
    url: 'https://spglobal.com/spdji/en/spiva/article/spiva-australia ',
  ),
  'bitcoin_whitepaper': ResearchRef(
    refId: 'bitcoin_whitepaper',
    source: 'Bitcoin: A Peer-to-Peer Electronic Cash System – Satoshi Nakamoto',
    year: '2008',
    plainSummary: 'The original Bitcoin whitepaper, publicly available. The genesis block – the first Bitcoin block – was mined on January 3, 2009 and is permanently recorded on the blockchain.',
    url: 'https://bitcoin.org/bitcoin.pdf ',
  ),
  'hal_finney': ResearchRef(
    refId: 'hal_finney',
    source: 'Bitcoin Magazine – documented interviews with Fran Finney',
    year: '2014',
    plainSummary: 'Fran Finney has spoken publicly about her husband Hal\'s role as the first Bitcoin recipient and her own relationship with the technology as a store of value.',
    url: 'https://bitcoinmagazine.com ',
  ),
};
