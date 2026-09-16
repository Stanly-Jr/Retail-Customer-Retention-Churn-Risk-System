# Retail Customer Retention, Churn Risk & Unit Economics Pipeline

## Executive Summary
This project delivers an end-to-end data science and business analytics system built to analyze customer lifetime engagement, evaluate unit economics, score churn propensity, and quantify revenue at risk for targeting.

Designed specifically for enterprise retail contexts, the pipeline features a **leakage-free temporal modeling architecture** that benchmarks Logistic Regression against Random Forest classifiers, coupled with an interactive Power BI dashboard for executive reporting.

---

## Business Impact & Key Metrics
* **At-Risk Revenue Isolated:** Identified **$263,532** in net revenue tied to high-value customers exhibiting early churn signals.
* **Wholesale Unit Economics:** Evaluated an Average Order Value (**AOV**) of **$353.93** across 23,587 distinct order transactions.
* **Key Retention Driver:** Identified order frequency as the primary retention lever—every standard deviation increase in `frequency_count` reduces customer churn odds by **66.6%** ($OR = 0.33$).

---

## Technical Architecture & Stack

Raw Transaction Logs (500k+)
│
▼ 
[Python / Pandas]
Data Cleaning, Return Flagging & Net Unit Economics Handling
│
▼ 
[MySQL Data Warehouse]
Indexed Star Schema (fact_transactions, dim_customers, dim_products)
│

├──► [MySQL Views] ──► NTILE() RFM Behavioral Segmentation
│
├──► [Scikit-Learn] ──► Leakage-Free Temporal Churn Model (Observation vs. Performance)
│
└──► [Power BI / DAX] ──► Executive Interactive Dashboard


* **Data Engineering:** Python (Pandas, SQLAlchemy) for ingestion and cleaning.
* **Data Warehousing:** MySQL Star Schema with custom B-Tree indexes on foreign keys to optimize join execution.
* **Behavioral Analytics:** SQL CTEs, window functions (`NTILE`), and temporal relative date math.
* **Predictive Modeling:** Scikit-Learn (`StandardScaler`, `LogisticRegression`, `RandomForestClassifier`).
* **Business Intelligence:** Power BI, DAX measures (`CALCULATE`, `DISTINCTCOUNT`, `DIVIDE`), cross-filtering slicers.

---

## Machine Learning & Governance

### Preventing Data Leakage
Standard churn models often suffer from target leakage by using lifetime features to predict lifetime targets. This pipeline enforces a strict **temporal split**:
* **Observation Window ($\le T$):** Calculates Recency, Tenure, Purchase Velocity, AOV, and Monetary Value up to cutoff date $T$.
* **Performance Window ($> T$):** Observes actual customer purchasing behavior in the subsequent 90-day window to derive the binary label `is_churned`.

### Model Evaluation & Selection
| Model | ROC-AUC | PR-AUC | Governance / Interpretability |
| :--- | :---: | :---: | :--- |
| **Logistic Regression** | **0.6996** | **0.5519** | **High** (Direct Odds Ratios, Transparent Coefficients) |
| **Random Forest** | **0.7072** | **0.5718** | Medium (Black-Box Ensemble) |

**Model Choice:** Logistic Regression was selected for production deployment. Because Random Forest provided minimal performance lift (+0.0076 ROC-AUC), Logistic Regression was prioritized to align with regulatory explainability and model governance standards.

---

## Repository Setup & Execution

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/your-username/jpmc-customer-retention-analytics.git](https://github.com/your-username/jpmc-customer-retention-analytics.git)
   cd jpmc-customer-retention-analytics
2. Install dependencies:

```bash
pip install -r requirements.txt
```
3. Database & Pipeline Execution:

Execute sql/01_schema_setup.sql in MySQL.

Run python src/data_ingestion.py to populate the database.

Execute sql/02_rfm_segmentation.sql to generate analytical views.

Run python src/churn_prediction.py to output model evaluation metrics and feature odds ratios.


***

### 4. Git Commands to Push Your Code

Open your terminal or command prompt in your project root directory and run:

```bash
# Initialize git
git init

# Add all files
git add .

# Commit files
git commit -m "feat: complete end-to-end churn analytics and modeling pipeline"

# Create main branch and link your remote GitHub repo
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/jpmc-customer-retention-analytics.git

# Push to GitHub
git push -u origin main
```
