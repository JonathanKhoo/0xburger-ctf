# 0xBURGER Hidden Flags Writeup

This page documents three hidden website mini-challenges. The flags are intentionally not printed here; follow the steps to recover them.

## 1) Crypto — Vigenere Sauce

Entry point:

```text
./cipher
```

The terminal prints a Vigenere ciphertext and hints that the key is the thing every order starts with.

Solve:

```python
cipher = "DNW{bmxfhvxi_jbotk_wvspvj_lfu}"
key = "BURGER"
out = []
ki = 0
for ch in cipher:
    if ch.isalpha():
        base = 65 if ch.isupper() else 97
        shift = ord(key[ki % len(key)].lower()) - 97
        out.append(chr((ord(ch) - base - shift) % 26 + base))
        ki += 1
    else:
        out.append(ch)
print(''.join(out))
```

## 2) Misc — Zero-Width Crumbs

Entry point:

```text
./crumbs
```

The visible text is normal, but the payload is stored in the `data-zero` attribute using zero-width characters.

Solve in browser console:

```js
const z = document.querySelector('#crumbTrail').dataset.zero;
const bits = [...z].map(c => c === '\u200b' ? '0' : '1').join('');
console.log(bits.match(/.{8}/g).map(b => String.fromCharCode(parseInt(b, 2))).join(''));
```

## 3) Reverse — Patty VM

Entry point:

```text
./patty-vm
```

The bytecode uses a tiny stack VM:

- `1 n`: push byte `n`
- `2 n`: XOR top of stack with `n`
- `3 n`: add `n` to top of stack
- `4`: output top of stack as a character

Solve:

```python
code = [
  1,31,2,35,3,7,4,1,110,2,35,3,7,4,1,28,2,35,3,7,4,1,87,2,35,3,7,4,
  1,72,2,35,3,7,4,1,125,2,35,3,7,4,1,76,2,35,3,7,4,1,125,2,35,3,7,4,
  1,72,2,35,3,7,4,1,79,2,35,3,7,4,1,125,2,35,3,7,4,1,123,2,35,3,7,4,
  1,78,2,35,3,7,4,1,66,2,35,3,7,4,1,125,2,35,3,7,4,1,123,2,35,3,7,4,
  1,74,2,35,3,7,4,1,121,2,35,3,7,4,1,78,2,35,3,7,4,1,78,2,35,3,7,4,
  1,81,2,35,3,7,4,1,123,2,35,3,7,4,1,76,2,35,3,7,4,1,69,2,35,3,7,4,
  1,85,2,35,3,7,4
]
stack = []
out = []
i = 0
while i < len(code):
    op = code[i]
    i += 1
    if op == 1:
        stack.append(code[i]); i += 1
    elif op == 2:
        stack[-1] ^= code[i]; i += 1
    elif op == 3:
        stack[-1] += code[i]; i += 1
    elif op == 4:
        out.append(chr(stack.pop()))
print(''.join(out))
```
