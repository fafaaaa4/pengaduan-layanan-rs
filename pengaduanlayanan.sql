-- =========================================================
-- PostgreSQL schema for Kuesioner Kepuasan Pasien
-- Compatible with PostgreSQL 12+ (tested conceptually for 17)
-- =========================================================

-- OPTIONAL: kalau mau reset total (hapus tabel lalu buat ulang)
-- HATI-HATI: ini akan menghapus data lama
DROP TABLE IF EXISTS kuesioner CASCADE;
DROP TABLE IF EXISTS formulir CASCADE;
DROP TABLE IF EXISTS profil CASCADE;
DROP TABLE IF EXISTS responden CASCADE;
DROP TABLE IF EXISTS nilai CASCADE;
DROP TABLE IF EXISTS layanan CASCADE;
DROP TABLE IF EXISTS asuransi CASCADE;

-- ========== MASTER TABLES ==========

CREATE TABLE asuransi (
  id INTEGER PRIMARY KEY,
  nama_asuransi VARCHAR(50)
);

CREATE TABLE layanan (
  id INTEGER PRIMARY KEY,
  nama_layanan VARCHAR(100)
);

CREATE TABLE nilai (
  id INTEGER PRIMARY KEY,
  keterangan INTEGER
);

CREATE TABLE responden (
  id INTEGER PRIMARY KEY,
  pertanyaan TEXT
);

-- ========== OPTIONAL TABLES (legacy, not used by current index.php) ==========

CREATE TABLE profil (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  jenis_kelamin SMALLINT NOT NULL DEFAULT 0,
  pekerjaan VARCHAR(255) NOT NULL,
  pendidikan VARCHAR(50) NOT NULL,
  asuransi_id INTEGER NOT NULL,
  layanan_id INTEGER NOT NULL,
  CONSTRAINT fk_profil_asuransi FOREIGN KEY (asuransi_id) REFERENCES asuransi(id),
  CONSTRAINT fk_profil_layanan FOREIGN KEY (layanan_id) REFERENCES layanan(id)
);

CREATE TABLE formulir (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  alamat TEXT,
  no_hp VARCHAR(30),
  masukan TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  tanggal DATE,
  profil_id BIGINT,
  CONSTRAINT fk_formulir_profil FOREIGN KEY (profil_id) REFERENCES profil(id)
);

-- ========== MAIN TABLE USED BY index.php ==========

CREATE TABLE kuesioner (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  survey_date DATE NOT NULL,
  survey_time VARCHAR(20) NOT NULL,

  gender VARCHAR(10) NOT NULL,        -- "male" / "female"
  education VARCHAR(10) NOT NULL,     -- "sd/smp/sma/s1/s2/s3"

  jobs TEXT NOT NULL,                 -- contoh: "pns,swasta"
  services TEXT NOT NULL,             -- contoh: "igd,lab"

  q1 SMALLINT NOT NULL,
  q2 SMALLINT NOT NULL,
  q3 SMALLINT NOT NULL,
  q4 SMALLINT NOT NULL,
  q5 SMALLINT NOT NULL,
  q6 SMALLINT NOT NULL,
  q7 SMALLINT NOT NULL,
  q8 SMALLINT NOT NULL,
  q9 SMALLINT NOT NULL,

  nama_pasien VARCHAR(150) NOT NULL,
  alamat TEXT NOT NULL,
  nomor_hp VARCHAR(30) NOT NULL,
  keluhan TEXT,

  CONSTRAINT chk_q1 CHECK (q1 BETWEEN 1 AND 4),
  CONSTRAINT chk_q2 CHECK (q2 BETWEEN 1 AND 4),
  CONSTRAINT chk_q3 CHECK (q3 BETWEEN 1 AND 4),
  CONSTRAINT chk_q4 CHECK (q4 BETWEEN 1 AND 4),
  CONSTRAINT chk_q5 CHECK (q5 BETWEEN 1 AND 4),
  CONSTRAINT chk_q6 CHECK (q6 BETWEEN 1 AND 4),
  CONSTRAINT chk_q7 CHECK (q7 BETWEEN 1 AND 4),
  CONSTRAINT chk_q8 CHECK (q8 BETWEEN 1 AND 4),
  CONSTRAINT chk_q9 CHECK (q9 BETWEEN 1 AND 4)
);

CREATE TABLE IF NOT EXISTS keluhan (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  nama_pasien TEXT NOT NULL,
  alamat TEXT NOT NULL,
  nomor_hp TEXT NOT NULL,
  keluhan TEXT
);

CREATE TABLE IF NOT EXISTS kepuasan (
  id BIGSERIAL PRIMARY KEY,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),

  survey_date DATE NOT NULL,
  survey_time VARCHAR(20) NOT NULL,

  gender VARCHAR(20) NOT NULL,
  education VARCHAR(20) NOT NULL,
  jobs TEXT NOT NULL,
  services VARCHAR(50) NOT NULL,

  q1 SMALLINT NOT NULL,
  q2 SMALLINT NOT NULL,
  q3 SMALLINT NOT NULL,
  q4 SMALLINT NOT NULL,
  q5 SMALLINT NOT NULL,
  q6 SMALLINT NOT NULL,
  q7 SMALLINT NOT NULL,
  q8 SMALLINT NOT NULL,
  q9 SMALLINT NOT NULL,

  penjamin VARCHAR(10) NOT NULL
);
-- ========== SEED DATA ==========

INSERT INTO asuransi (id, nama_asuransi) VALUES
  (1, 'BPJS'),
  (2, 'UMUM')
ON CONFLICT (id) DO NOTHING;

INSERT INTO layanan (id, nama_layanan) VALUES
  (1, 'ADMISI'),
  (2, 'IGD'),
  (3, 'LABORATORIUM'),
  (4, 'FARMASI'),
  (5, 'RAWAT INAP'),
  (6, 'OPERASI'),
  (7, 'RAWAT JALAN'),
  (8, 'RADIOLOGI'),
  (9, 'ICU'),
  (10, 'GIZI')
ON CONFLICT (id) DO NOTHING;

INSERT INTO nilai (id, keterangan) VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4)
ON CONFLICT (id) DO NOTHING;

INSERT INTO responden (id, pertanyaan) VALUES
  (2, 'Bagaimana pendapat saudara tentang kesesuaian persyaratan pelayanan dengan jenis pelayanannya?'),
  (3, 'Bagaimana pemahaman Anda tentang kemudahan prosedur pelayanan di unit ini?'),
  (4, 'Bagaimana pendapat Anda tentang kecepatan waktu dalam memberikan pelayanan?'),
  (5, 'Bagaimana pendapat Anda tentang kewajaran biaya/tarif dalam pelayanan? (Jika peserta BPJS/Asuransi tidak perlu diisi)'),
  (6, 'Bagaimana pendapat Anda tentang kesesuaian produk pelayanan antara yang tercantum dalam standar pelayanan dengan hasil yang diberikan?'),
  (7, 'Bagaimana pendapat Anda tentang kompetensi/kemampuan petugas dalam pelayanan?'),
  (8, 'Bagaimana pendapat Anda tentang perilaku petugas dalam pelayanan terkait kesopanan dan keramahan?'),
  (9, 'Bagaimana pendapat Anda tentang penanganan pengaduan pengguna layanan?'),
  (10,'Bagaimana pendapat Anda tentang kualitas sarana dan prasarana?')
ON CONFLICT (id) DO NOTHING;