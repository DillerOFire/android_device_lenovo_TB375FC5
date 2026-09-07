/*
 * Bridge Android 16 wpa_supplicant's renamed BoringSSL stack API to the
 * Android 14 VNDK crypto ABI required by Lenovo vendor binaries.
 */
#include <stddef.h>

typedef struct stack_st OPENSSL_STACK;
typedef struct x509_lookup_st X509_LOOKUP;
typedef void (*OPENSSL_sk_free_func)(void*);
typedef void (*OPENSSL_sk_call_free_func)(OPENSSL_sk_free_func, void*);

extern OPENSSL_STACK* sk_new_null(void);
extern size_t sk_num(const OPENSSL_STACK*);
extern void* sk_value(const OPENSSL_STACK*, size_t);
extern void sk_free(OPENSSL_STACK*);
extern void* sk_pop(OPENSSL_STACK*);
extern size_t sk_push(OPENSSL_STACK*, void*);
extern int X509_LOOKUP_ctrl(X509_LOOKUP*, int, const char*, long, char**);

int X509_LOOKUP_load_file(X509_LOOKUP* lookup, const char* file, int type) {
    return X509_LOOKUP_ctrl(lookup, 1 /* X509_L_FILE_LOAD */, file, type, NULL);
}

OPENSSL_STACK* OPENSSL_sk_new_null(void) { return sk_new_null(); }
size_t OPENSSL_sk_num(const OPENSSL_STACK* stack) { return sk_num(stack); }
void* OPENSSL_sk_value(const OPENSSL_STACK* stack, size_t index) { return sk_value(stack, index); }
void OPENSSL_sk_free(OPENSSL_STACK* stack) { sk_free(stack); }
void* OPENSSL_sk_pop(OPENSSL_STACK* stack) { return sk_pop(stack); }
size_t OPENSSL_sk_push(OPENSSL_STACK* stack, void* value) { return sk_push(stack, value); }

OPENSSL_STACK* OPENSSL_sk_dup(const OPENSSL_STACK* stack) {
    OPENSSL_STACK* copy = sk_new_null();
    size_t i;
    if (copy == NULL) return NULL;
    for (i = 0; i < sk_num(stack); ++i) {
        if (!sk_push(copy, sk_value(stack, i))) {
            sk_free(copy);
            return NULL;
        }
    }
    return copy;
}

void OPENSSL_sk_pop_free_ex(OPENSSL_STACK* stack,
                            OPENSSL_sk_call_free_func call_free,
                            OPENSSL_sk_free_func free_func) {
    void* value;
    while ((value = sk_pop(stack)) != NULL) {
        call_free(free_func, value);
    }
    sk_free(stack);
}

/* BOARD_WPA_SUPPLICANT_PRIVATE_LIB disables AOSP's generic stub library. */
typedef unsigned char u8;
struct wpabuf;

int wpa_driver_nl80211_driver_cmd(void* priv, char* cmd, char* buf, size_t len) {
    return 0;
}
int wpa_driver_set_p2p_noa(void* priv, u8 count, int start, int duration) {
    return 0;
}
int wpa_driver_get_p2p_noa(void* priv, u8* buf, size_t len) {
    return 0;
}
int wpa_driver_set_p2p_ps(void* priv, int legacy_ps, int opp_ps, int ctwindow) {
    return -1;
}
int wpa_driver_set_ap_wps_p2p_ie(void* priv, const struct wpabuf* beacon,
                                 const struct wpabuf* proberesp,
                                 const struct wpabuf* assocresp) {
    return 0;
}
