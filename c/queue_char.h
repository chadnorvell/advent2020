struct queue_char {
    int max_size;
    int size;
    int front;
    int rear;
    char *items;
};

struct queue_char queue_char_new(char *items, int max_size);
void queue_char_enqueue(struct queue_char *queue, char x);
char queue_char_dequeue(struct queue_char *queue);
