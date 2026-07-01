# 0xBURGER Hidden Flags — Progressive Hints

This is a progressive hint sheet. Stop as soon as you have enough.

No plaintext flags are printed here.

## Crypto — Vigenere Sauce

Entry point:

```text
./cipher
```

### Hint 1
The braces and underscores survive, so this is probably a letter-only substitution or polyalphabetic cipher.

### Hint 2
The title and website theme matter. The key is not random; it is one of the most repeated words on the page.

### Hint 3
Try a classic cipher where a repeated keyword shifts each alphabetic character.

### Spoiler Solve
Use Vigenere decrypt with the site-theme keyword.

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

## Misc — Zero-Width Crumbs

Entry point:

```text
./crumbs
```

### Hint 1
The output looks too short for a real challenge. Look at the DOM, not just the visible text.

### Hint 2
The phrase says some crumbs are too thin to see. Some Unicode characters render with no width.

### Hint 3
There are two invisible characters. Treat them as binary.

### Spoiler Solve
Read the hidden attribute and map the two zero-width characters to bits.

```js
const z = document.querySelector('#crumbTrail').dataset.zero;
const bits = [...z].map(c => c === '\u200b' ? '0' : '1').join('');
console.log(bits.match(/.{8}/g).map(b => String.fromCharCode(parseInt(b, 2))).join(''));
```

## Reverse — Patty VM

Entry point:

```text
./patty-vm
```

### Hint 1
The repeating pattern matters more than the individual numbers.

### Hint 2
The first number in each group behaves like an instruction, not data.

### Hint 3
There are four operations. One loads a byte, two mutate it, one emits it.

### Spoiler Solve
Interpret the bytecode as a tiny stack VM.

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
