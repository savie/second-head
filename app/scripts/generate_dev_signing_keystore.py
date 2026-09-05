#!/usr/bin/env python3
"""Create the deterministic SH DEV debug signing keystore from a secret seed.

The same seed produces the same RSA private key and self-signed certificate on
Every CI run. The generated PKCS#12 keystore is intentionally kept ephemeral;
only the seed lives in GitHub Actions Secrets.
"""
from cryptography import x509
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.serialization import pkcs12
from cryptography.x509.oid import NameOID
from datetime import datetime, timezone
import hashlib
import hmac
import os
import sys

BITS = 1024
E = 65537


def candidate(seed: bytes, label: bytes, index: int) -> int:
    raw = hmac.new(seed, label + index.to_bytes(8, "big"), hashlib.sha256).digest()
    blocks = [raw]
    counter = 1
    while len(b"".join(blocks)) * 8 < BITS:
        blocks.append(hmac.new(seed, label + index.to_bytes(8, "big") + counter.to_bytes(4, "big"), hashlib.sha256).digest())
        counter += 1
    value = int.from_bytes(b"".join(blocks), "big") & ((1 << BITS) - 1)
    value |= 3 << (BITS - 2)
    value |= 1
    return value


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    for p in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if n % p == 0:
            return n == p
    d = n - 1
    s = 0
    while d % 2 == 0:
        s += 1
        d //= 2
    for a in (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37):
        if a >= n:
            continue
        x = pow(a, d, n)
        if x in (1, n - 1):
            continue
        for _ in range(s - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def prime(seed: bytes, label: bytes) -> int:
    index = 0
    while True:
        value = candidate(seed, label, index)
        if is_prime(value) and (value - 1) % E != 0:
            return value
        index += 1


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: generate_dev_signing_keystore.py <output>")
    seed_text = os.environ.get("SH_DEV_SIGNING_SEED")
    if seed_text is None:
        raise SystemExit("SH_DEV_SIGNING_SEED environment variable is required")
    seed = seed_text.encode("utf-8")
    output = sys.argv[1]

    p = prime(seed, b"SH-DEV-RSA-P")
    q = prime(seed, b"SH-DEV-RSA-Q")
    if p == q:
        raise SystemExit("deterministic RSA prime collision")
    if p < q:
        p, q = q, p

    n = p * q
    phi = (p - 1) * (q - 1)
    d = pow(E, -1, phi)
    key = rsa.RSAPrivateNumbers(
        p=p,
        q=q,
        d=d,
        dmp1=d % (p - 1),
        dmq1=d % (q - 1),
        iqmp=pow(q, -1, p),
        public_numbers=rsa.RSAPublicNumbers(E, n),
    ).private_key()

    subject = x509.Name(
        [
            x509.NameAttribute(NameOID.COMMON_NAME, "Android Debug"),
            x509.NameAttribute(NameOID.ORGANIZATION_NAME, "Android"),
            x509.NameAttribute(NameOID.COUNTRY_NAME, "US"),
        ]
    )
    serial = int.from_bytes(hashlib.sha256(seed + b":serial").digest(), "big") & ((1 << 159) - 1)
    serial = max(serial, 1)
    cert = (
        x509.CertificateBuilder()
        .subject_name(subject)
        .issuer_name(subject)
        .public_key(key.public_key())
        .serial_number(serial)
        .not_valid_before(datetime(2020, 1, 1, tzinfo=timezone.utc))
        .not_valid_after(datetime(2050, 1, 1, tzinfo=timezone.utc))
        .sign(key, hashes.SHA256())
    )

    blob = pkcs12.serialize_key_and_certificates(
        b"androiddebugkey",
        key,
        cert,
        None,
        serialization.BestAvailableEncryption(b"android"),
    )
    os.makedirs(os.path.dirname(output), exist_ok=True)
    with open(output, "wb") as handle:
        handle.write(blob)
    print(cert.fingerprint(hashes.SHA256()).hex())


if __name__ == "__main__":
    main()
