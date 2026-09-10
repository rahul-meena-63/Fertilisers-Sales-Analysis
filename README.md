# 🌾 Fertilisers Sales Dashboard

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Python](https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white)
![Power BI](https://img.shields.io/badge/Power_BI-F2C811?logo=powerbi&logoColor=black)
![SQL](https://img.shields.io/badge/SQL-4479A1?logo=postgresql&logoColor=white)
![Excel](https://img.shields.io/badge/Excel-217346?logo=microsoftexcel&logoColor=white)

A business intelligence and data analytics project developed to analyze fertiliser sales performance using interactive visualizations and KPIs. It transforms raw sales data into meaningful business decisions through visual storytelling.

🚀 **Business Impact & Objective:** Solves the challenge of managing IFFCO's fertiliser distribution across multiple regions and product categories. It replaces traditional reporting methods with dynamic tracking, enabling faster identification of trends, revenue growth tracking, and timely strategic decision-making.

---

## ✨ Features & Key Insights

* 📊 **Sales Performance Monitoring:** Tracks total sales revenue efficiently across selected periods and identifies distinct monthly and yearly sales trends.
* 📦 **Deep Product Analysis:** Highlights top-selling fertiliser products and accurately measures individual product category contributions.
* 🌍 **Regional Intelligence:** Identifies high-performing regions and analyzes sales distribution across states to understand local customer demand.
* 💡 **Strategic Recommendations:** Converts raw data into actionable strategies—such as promoting low-performing products, monitoring seasonal patterns, and expanding focus on top revenue-generating categories.

---

## 💻 Tech Stack

| Layer | Technology |
| ----- | ---------- |
| **Dashboard Development** | Power BI |
| **Cloud Platform** | Azure |
| **Data Warehouse** | Snowflake |
| **Data Processing** | SQL, Microsoft Excel, Python |
| **Python Libraries** | Pandas, NumPy, Matplotlib, Warnings |

---

## 📈 Business KPIs

| Metric | Measurement Focus |
| ------ | ----------------- |
| **Total Revenue** | Overall financial performance and top-line growth |
| **Total Sales Quantity**| Volume of fertiliser products distributed |
| **Average Sales** | Revenue consistency per transaction/period |
| **Growth Percentage** | Period-over-period business expansion |

---

## 🔄 Data Pipeline & Workflow

☁️ **Azure** ➔ ❄️ **Snowflake** ➔ ⚙️ **SQL** ➔ 📊 **Power BI**  

The project follows a modern end-to-end data engineering pipeline to ensure high performance, scalability, and automated reporting:

* ☁️ **Ingestion (Azure):** Raw sales data is securely stored in Azure Blob Storage.
* ❄️ **Warehousing (Snowflake):** Data is seamlessly loaded into the Snowflake Data Cloud.
* ⚙️ **Transformation (SQL):** SQL scripts inside Snowflake clean, model, and prepare the data.
* 📊 **Visualization (Power BI):** Power BI connects to the final Snowflake views to build interactive dashboards.

---

## 📁 Project Structure

```text
IFFCO-FERTILISERS-SALES-DASHBOARD
├── data/
│   ├── raw_data.csv
│   └── analysed_data.xlsx
└── images/
    ├── Dashboard-preview.png
    └── Product-scorecard.png
