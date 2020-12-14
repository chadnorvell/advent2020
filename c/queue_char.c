#include <stdio.h>
#include <stdlib.h>

#include "queue_char.h"

struct queue_char queue_char_new(char *items, int max_size) {
    struct queue_char queue = { max_size, 0, 0, -1, items };
    return queue;
}

void queue_char_enqueue(struct queue_char *queue, char x) {
    queue->rear = (queue->rear + 1) % queue->max_size;
    queue->items[queue->rear] = x;
    queue->size++;
}

char queue_char_dequeue(struct queue_char *queue) {
    if(queue->size == 0) {
        printf("underrun!\n");
        exit(1);
    }

    char val = queue->items[queue->front];
    queue->front = (queue->front + 1) % queue->max_size;
    queue->size--;

    return val;
}
