import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path
from datetime import datetime

data_dir = Path('data')
visuals_dir = Path('visuals')
visuals_dir.mkdir(exist_ok=True)

members = pd.read_csv(data_dir / 'members.csv', parse_dates=['join_date', 'cancel_date'])
visits = pd.read_csv(data_dir / 'visits.csv', parse_dates=['visit_date'])

members['join_month'] = members['join_date'].dt.to_period('M').dt.to_timestamp()
members['cancel_month'] = members['cancel_date'].dt.to_period('M').dt.to_timestamp()

months = pd.period_range(start=members['join_month'].min(), end=visits['visit_date'].max().to_period('M'), freq='M')

# Monthly Active Members
mam_list = []
for m in months:
    month_start = m.to_timestamp()
    active = ((members['join_month'] <= month_start) & ((members['cancel_month'].isna()) | (members['cancel_month'] >= month_start))).sum()
    mam_list.append({'month': month_start, 'active_members': active})
mam_df = pd.DataFrame(mam_list)

# Monthly Visits
visits['visit_month'] = visits['visit_date'].dt.to_period('M').dt.to_timestamp()
visits_df = visits.groupby('visit_month').size().reset_index(name='visits')

metrics = mam_df.merge(visits_df, left_on='month', right_on='visit_month', how='left').fillna(0)

plt.figure(figsize=(10,6))
plt.plot(metrics['month'], metrics['active_members'], label='Active Members')
plt.plot(metrics['month'], metrics['visits'], label='Visits')
plt.title('Monthly Active Members vs Visits')
plt.xlabel('Month')
plt.ylabel('Count')
plt.legend()
plt.tight_layout()
plt.savefig(visuals_dir / 'monthly_metrics.png')
plt.close()

# Cohort retention
members['cohort_month'] = members['join_month']
cohort_data = []
for cohort in members['cohort_month'].unique()[:6]:
    cohort_members = members[members['cohort_month'] == cohort]
    cohort_size = len(cohort_members)
    for period in range(0, 13):  # first 12 months
        month_check = (cohort + pd.DateOffset(months=period)).to_period('M').to_timestamp()
        active = ((cohort_members['join_month'] <= month_check) & ((cohort_members['cancel_month'].isna()) | (cohort_members['cancel_month'] >= month_check))).sum()
        cohort_data.append({'cohort_month': cohort, 'period': period, 'retention': active / cohort_size})
cohort_df = pd.DataFrame(cohort_data)

plt.figure(figsize=(10,6))
for cohort in cohort_df['cohort_month'].unique():
    subset = cohort_df[cohort_df['cohort_month'] == cohort]
    plt.plot(subset['period'], subset['retention'], label=str(cohort)[:10])
plt.title('Cohort Retention Curves (First 6 Cohorts)')
plt.xlabel('Months Since Signup')
plt.ylabel('Retention Rate')
plt.legend()
plt.tight_layout()
plt.savefig(visuals_dir / 'cohort_retention.png')
plt.close()