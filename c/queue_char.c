#include <stdio.h>
#include <stdlib.h>

#include "queue_char.h"

void queue_char_log(struct queue_char *queue) {
    printf("size: %d, front: %d, rear: %d, raw: [", queue->size, queue->front, queue->rear);

    for(int i=0; i < queue->max_size; i++) {
        printf(" %c,", queue->items[i]);
    }

    printf(" ]\n");
}

struct queue_char queue_char_new(char *items, int max_size) {
    struct queue_char queue = { max_size, 0, 0, -1, items };
    // queue_char_log(&queue);
    return queue;
}

void queue_char_enqueue(struct queue_char *queue, char x) {
    queue->rear = (queue->rear + 1) % queue->max_size;
    queue->items[queue->rear] = x;
    queue->size++;
    // queue_char_log(queue);
}

char queue_char_dequeue(struct queue_char *queue) {
    if(queue->size == 0) {
        printf("underrun!\n");
        exit(1);
    }

    char val = queue->items[queue->front];
    queue->front = (queue->front + 1) % queue->max_size;
    queue->size--;

    // queue_char_log(queue);
    return val;
}

void queue_char_reset(struct queue_char *queue) {
    queue->size = 0;
    queue->front = 0;
    queue->rear = -1;
    // queue_char_log(queue);
}

void queue_char_flush(struct queue_char *queue, char *buffer, int buffer_size) {
    int size_to_flush = queue->size;
    int flushed = 0;

    for(int i=0; i < size_to_flush; i++) {
        if(flushed < buffer_size) {
            buffer[i] = queue_char_dequeue(queue);
            flushed++;
        }
    }

    if(flushed <= buffer_size) {
        buffer[flushed] = '\0';
    }

    queue_char_reset(queue);
}
