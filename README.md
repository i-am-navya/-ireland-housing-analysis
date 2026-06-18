# Irish Residential Property Price Register - Market Analysis

A data analysis project exploring 748,051 residential property transactions 
in Ireland from 2010 to 2026 using Python, Pandas, and Matplotlib.

## Dataset
- **Source:** [Property Price Register](https://www.propertypriceregister.ie)
- **Coverage:** All residential property sales in Ireland from 2010 to 2026
- **Records analysed:** 748,051 transactions across 26 counties

## Tech Stack
- Python 3.14
- Pandas - data cleaning and analysis
- Matplotlib - data visualisation
- Seaborn - chart styling
- Jupyter Notebook

## Key Findings

| Metric | Value |
|---|---|
| National Median Price (2026) | €371,000 |
| Dublin Median Price (2026) | €480,000 |
| Dublin Premium | €109,000 |
| Most Expensive County | Dublin - €480,000 |
| Most Affordable County | Longford - €191,000 |
| Price Gap | €289,000 |
| Second-Hand Market Share | 82.4% |
| New Build Market Share | 17.6% |

## Analysis Includes
1. National median price trend (2010-2026)
2. Property type distribution - New Build vs Second-Hand
3. Number of transactions per year
4. Top 10 most expensive counties
5. Median price across all 26 counties
6. Dublin vs National price comparison
7. New Build vs Second-Hand price comparison over time
8. Summary of key market findings

## How to Run

```bash
git clone https://github.com/i-am-navya/-ireland-housing-analysis.git
cd -ireland-housing-analysis
pip install pandas matplotlib seaborn jupyter
```

Download the dataset from [propertypriceregister.ie](https://www.propertypriceregister.ie) 
and save as `PPR-ALL.csv` in the project folder, then open the notebook:

```bash
jupyter notebook housing_analysis.ipynb
```

## Author
Navya Zacharia
[LinkedIn](https://linkedin.com/in/navya-zacharia-0853621ba) | [GitHub](https://github.com/i-am-navya)
