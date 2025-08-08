import streamlit as st
import helper
import preprocessor
import matplotlib.pyplot as plt



st.sidebar.title("WhisperWise")


uploaded_file = st.sidebar.file_uploader("Choose a file")
if uploaded_file is not None:
    bytes_data = uploaded_file.getvalue()
    data = bytes_data.decode("utf-8")
    df = preprocessor.preprocess(data)
    st.dataframe(df)

    user_list = df['user'].unique().tolist()
    user_list.remove('group_notification')
    user_list.sort()
    user_list.insert(0,"Overall")

    selected_user = st.sidebar.selectbox("Show analysis wrt", user_list)

    if st.sidebar.button("Show Analysis"):

        # Stats Area
        num_messages,words,num_media_messages,links = helper.fetch_stats(selected_user, df)
        col1, col2, col3, col4 = st.columns(4)

        with col1:
            st.header("Total Messages")
            st.title(num_messages)
        with col2:
            st.header("Total Words")
            st.title(words)
        with col3:
            st.header("Total Media")
            st.title(num_media_messages)
        with col4:
            st.header("Total links")
            st.title(links)
#Most busy user

        if selected_user =='overall':
            st.title('Most Busy User')
            x= helper.most_busy_users(df)
            fig, ax= plt.subplots()
            col1,col2= st.columns(2)

            with col1:
                ax.bar(x.index, x.values)
                st.pyplot(fig)

#word cloud

        st.title("Wordcloud")
        df_wc = helper.create_wordcloud(selected_user, df)
        fig, ax = plt.subplots()
        ax.imshow(df_wc)
        st.pyplot(fig)

        #most common words

        most_common_df = helper.most_common_words(selected_user, df)
        fig,ax= plt.subplots()
        ax.bar(most_common_df['word'],most_common_df['count'])
        plt.xticks(rotation='vertical')
        st.pyplot(fig)

    # MONTHLY TIMELINE
        timeline = helper.monthly_timeline(selected_user, df)
        fig, ax = plt.subplots()
        ax.plot(timeline['time'], timeline['message'])
        plt.xticks(rotation='vertical')
        st.pyplot(fig)

   # Emotion Analysis
        st.title("Emotion Analysis")
        emotion_counts = helper.analyze_emotions(selected_user, df)

        if not emotion_counts.empty:
           fig, ax = plt.subplots()
           ax.bar(emotion_counts.index, emotion_counts.values)
           st.pyplot(fig)
        else:
           st.write("No emotions detected.")



