Download metadata:
---

```bash
cd audioset/
curl -JLO https://raw.githubusercontent.com/audioset/ontology/master/ontology.json
curl -JLO http://storage.googleapis.com/us_audioset/youtube_corpus/v1/csv/eval_segments.csv
curl -JLO http://storage.googleapis.com/us_audioset/youtube_corpus/v1/csv/balanced_train_segments.csv
curl -JLO http://storage.googleapis.com/us_audioset/youtube_corpus/v1/csv/unbalanced_train_segments.csv
```

Example usage:
---

```bash
DATASET=audioset_instruments/balanced_train
DST=/mnt/hdd0/scrape/youtube-audio/dl

mkdir -p ${DST}/${DATASET}

# Create `videos.txt`.
cat ${DATASET}_segments.csv | grep -v '^#' | awk -F, '{print $1}' | uniq >${DST}/${DATASET}/videos.txt

# Download dataset (can interrupt and restart, may need to run multiple times).
NUM_PARALLEL=32 bash download.sh ${DST}/${DATASET}

# Extract segments.
cat ${DATASET}_segments.csv | awk -F, '{print $1,$2,$3}' | (cd ${DST}/${DATASET} && mkdir -p cut/ && xargs -l -P 12 bash -c 'ffmpeg -i complete/$0/$0*.m4a -ss $1 -to $2 cut/$0.ogg')
```
