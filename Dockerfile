# set up the base image
FROM python:3.12
# set the working directory
WORKDIR /app/
# copy the requirements file to workdir
COPY requirements.txt .
# install the requirements
RUN pip install -r requirements.txt
# Copy all required data files at once
COPY ./data/collab_filtered_data.csv \
     ./data/interaction_matrix.npz \
     ./data/track_ids.npy \
     ./data/cleaned_data.csv \
     ./data/transformed_data.npz \
     ./data/transformed_hybrid_data.npz \
     ./data/
# Copy all required Python scripts at once
COPY app.py \
     collaborative_filtering.py \
     content_based_filtering.py \
     hybrid_recommendations.py \
     data_cleaning.py \
     transform_filtered_data.py \
     ./
# Create logs directory
RUN mkdir -p /app/logs
# Create a wrapper script to run the app with logging
RUN echo '#!/bin/bash\n\
LOG_FILE="/app/logs/streamlit_app_$(date +%Y%m%d_%H%M%S).log"\n\
echo "Starting application at $(date)" | tee -a $LOG_FILE\n\
streamlit run app.py --server.port 8000 --log_level debug 2>&1 | tee -a $LOG_FILE\n\
' > /app/start_with_logging.sh && chmod +x /app/start_with_logging.sh
# expose the port on the container
EXPOSE 8000
# run the app with logging
CMD [ "/app/start_with_logging.sh" ]