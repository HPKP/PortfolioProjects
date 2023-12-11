#!/usr/bin/env python
# coding: utf-8

# # IMPORT LIBRARIES

# In[1]:


import pandas as pd
import seaborn as sns
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

get_ipython().run_line_magic('matplotlib', 'inline')
matplotlib.rcParams['figure.figsize'] = (12,8) # Adjust the configurations of the plots we will create


# Read in the data

df = pd.read_csv(r'C:\Users\Ethan\Downloads\archive\movies.csv')


# In[2]:


# Lets look at the data

df.head()


# In[3]:


# Checking for missing data

for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{}-{}%'.format(col,pct_missing))
    


# In[4]:


# Datatypes for the columns
df.dtypes


# In[5]:


# Changing datatype of 'budget'  and 'gross' fields to 'integer'

df['budget'] = df['budget'].fillna(0).astype('int64') # use fillna() to fill NaN values before type casting else will throw errors
df['gross'] = df['gross'].fillna(0).astype('int64')


# In[6]:


# Print data frame after datatype correction
df.head()


# In[7]:


# Correct the 'released' year column

#df['CorrectedReleaseYear'] = df['released'].astype('str').str[:4]
#df['CorrectedReleaseYear'] = pd.to_datetime(df['released'].str.split(' \(').str[0],infer_datetime_format=True)
#df['CorrectedReleaseYear'] = pd.to_datetime((df['released'].str.split(r'(')).str[0],infer_datetime_format=True))

#df["new_column"] = pd.to_datetime(df['released'])

# df["new_column"] = df["released"].apply(lambda x: pd.to_datetime(x))


# In[8]:


# Print data frame after year correction
df.head()


# In[9]:


df = df.sort_values(by='gross',inplace=False,ascending=False)


# In[10]:


pd.set_option('display.max_rows',None)


# In[11]:


df.head()


# In[12]:


# Dropping duplicate values of company

df['company'].drop_duplicates().sort_values(ascending=False)

#Dropping duplicate values in the entire data frame
#df.drop_duplicates()


# In[13]:


# Budget high correlation
# Company high correlation


# In[14]:


# Scatter plot with budget VC gross

plt.scatter(x=df['budget'],y=df['gross'])
plt.title('BUDGET VS GROSS EARNINGS')
plt.xlabel('Gross Earnings')
plt.ylabel('Budget')
plt.show()


# In[15]:


df.head()


# In[16]:


# Plot budget VS Gross using seaborn

sns.regplot(x='budget',y='gross',data=df,scatter_kws={"color":"red"},line_kws={"color":"blue"})


# In[17]:


# Looking at the correlation
# Correlation works only on the numerical data 
#df.corr()

#Different correlation methods we can use - Pearson, Kendall, Spearman
# By Default correlation uses pearson method
df.corr(method="pearson")

# Results show high correlation between budget and gross


# In[18]:


correlation_matrix = df.corr(method="pearson")
sns.heatmap(correlation_matrix,annot=True)
plt.title("Correlation Matrix for Numeric Features")
plt.xlabel("Movie Features")
plt.ylabel("Movie Features")
plt.show()


# In[19]:


# Looking at Company field
df.head()


# In[20]:


df_numerized = df
for col_name in df_numerized.columns:
    if(df_numerized[col_name].dtype == 'object'):
        df_numerized[col_name] = df_numerized[col_name].astype('category')
        df_numerized[col_name] = df_numerized[col_name].cat.codes
df_numerized.head()


# In[21]:


correlation_matrix_numerized = df_numerized.corr(method="pearson")
sns.heatmap(correlation_matrix_numerized,annot=True)
plt.title("Correlation Matrix for Numeric Features")
plt.xlabel("Movie Features")
plt.ylabel("Movie Features")
plt.show()


# In[22]:


correlation_matrix = df_numerized.corr()
corr_pairs = correlation_matrix.unstack()
corr_pairs


# In[23]:


sorted_pairs = corr_pairs.sort_values()
sorted_pairs


# In[24]:


# Finding sorted pairs with a high correlation
high_corr = sorted_pairs[(sorted_pairs) > 0.5]
high_corr


# In[25]:


#Conclusion on correlation
# Votes and budget have the highest correlation to gross earnings
# Company has low correlation

