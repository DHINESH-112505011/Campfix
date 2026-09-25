"""
CampFix AI Training Pipeline
Dataset -> Clean text -> TF-IDF -> Train model -> Evaluate -> Save model
Per project rule: practical baseline (Logistic Regression / Linear SVM),
not deep learning, with honestly reported accuracy/precision/recall/F1.
"""

import pandas as pd
import joblib
import os
import re
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score, precision_recall_fscore_support, classification_report

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATASET_PATH = os.path.join(BASE_DIR, 'dataset', 'complaints_dataset.csv')
MODELS_DIR = os.path.join(BASE_DIR, 'models')

os.makedirs(MODELS_DIR, exist_ok=True)


def clean_text(text):
    text = text.lower()
    text = re.sub(r'[^a-z0-9\s]', '', text)
    text = re.sub(r'\s+', ' ', text).strip()
    return text


def train_and_evaluate(X_train, X_test, y_train, y_test, label_name):
    model = LogisticRegression(max_iter=1000)
    model.fit(X_train, y_train)

    predictions = model.predict(X_test)
    accuracy = accuracy_score(y_test, predictions)
    precision, recall, f1, _ = precision_recall_fscore_support(
        y_test, predictions, average='weighted', zero_division=0
    )

    print(f"\n--- {label_name} Classifier ---")
    print(f"Accuracy:  {accuracy:.3f}")
    print(f"Precision: {precision:.3f}")
    print(f"Recall:    {recall:.3f}")
    print(f"F1 Score:  {f1:.3f}")
    print(classification_report(y_test, predictions, zero_division=0))

    return model


def main():
    print("Loading dataset...")
    df = pd.read_csv(DATASET_PATH)
    df['clean_text'] = df['text'].apply(clean_text)

    print(f"Dataset size: {len(df)} rows")
    print(f"Categories: {df['category'].unique().tolist()}")
    print(f"Priorities: {df['priority'].unique().tolist()}")

    vectorizer = TfidfVectorizer(max_features=500, ngram_range=(1, 2))
    X = vectorizer.fit_transform(df['clean_text'])

    # Category model
    X_train, X_test, y_cat_train, y_cat_test = train_test_split(
        X, df['category'], test_size=0.2, random_state=42
    )
    category_model = train_and_evaluate(X_train, X_test, y_cat_train, y_cat_test, 'Category')

    # Priority model (same split indices reused via a second split on priority labels)
    _, _, y_pri_train, y_pri_test = train_test_split(
        X, df['priority'], test_size=0.2, random_state=42
    )
    priority_model = train_and_evaluate(X_train, X_test, y_pri_train, y_pri_test, 'Priority')

    # Save artifacts
    joblib.dump(vectorizer, os.path.join(MODELS_DIR, 'tfidf_vectorizer.pkl'))
    joblib.dump(category_model, os.path.join(MODELS_DIR, 'category_classifier.pkl'))
    joblib.dump(priority_model, os.path.join(MODELS_DIR, 'priority_classifier.pkl'))

    print(f"\nModels saved to {MODELS_DIR}")


if __name__ == '__main__':
    main()