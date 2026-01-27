<?php
session_start();

/* =========================
   KONFIG KONEKSI POSTGRESQL
   ========================= */
$db_host = "localhost";
$db_port = "5432";
$db_name = "pengaduanlayanan";   // samakan dengan database yang kamu buat
$db_user = "postgres";          // ganti jika user berbeda
$db_pass = "PASSWORD_POSTGRES_KAMU"; // <-- GANTI INI

$conn = pg_connect("host=$db_host port=$db_port dbname=$db_name user=$db_user password=$db_pass");
if (!$conn) {
  die("Koneksi PostgreSQL gagal. Cek host/port/db/user/password dan pastikan extension pgsql aktif di PHP.");
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

  $required_fields = [
    'surveyDate',
    'surveyTime',
    'gender',
    'education',
    'nama_pasien',
    'alamat',
    'nomor_hp',
    'q1',
    'q2',
    'q3',
    'q4',
    'q5',
    'q6',
    'q7',
    'q8',
    'q9'
  ];

  $is_valid = true;
  foreach ($required_fields as $field) {
    if (!isset($_POST[$field]) || empty(trim((string)$_POST[$field]))) {
      $is_valid = false;
      break;
    }
  }

  if (!isset($_POST['jobs']) || count($_POST['jobs']) === 0) $is_valid = false;
  if (!isset($_POST['services']) || count($_POST['services']) === 0) $is_valid = false;

  if ($is_valid) {
    // simpan jobs/services jadi string "a,b,c"
    $jobs = implode(',', array_map('trim', (array)$_POST['jobs']));
    $services = implode(',', array_map('trim', (array)$_POST['services']));

    $sql = "INSERT INTO kuesioner
      (survey_date, survey_time, gender, education, jobs, services,
       q1,q2,q3,q4,q5,q6,q7,q8,q9,
       nama_pasien, alamat, nomor_hp, keluhan)
      VALUES
      ($1,$2,$3,$4,$5,$6,
       $7,$8,$9,$10,$11,$12,$13,$14,$15,
       $16,$17,$18,$19)";

    $params = [
      $_POST['surveyDate'],
      $_POST['surveyTime'],
      $_POST['gender'],
      $_POST['education'],
      $jobs,
      $services,
      (int)$_POST['q1'],
      (int)$_POST['q2'],
      (int)$_POST['q3'],
      (int)$_POST['q4'],
      (int)$_POST['q5'],
      (int)$_POST['q6'],
      (int)$_POST['q7'],
      (int)$_POST['q8'],
      (int)$_POST['q9'],
      $_POST['nama_pasien'],
      $_POST['alamat'],
      $_POST['nomor_hp'],
      ($_POST['keluhan'] ?? null)
    ];

    $result = pg_query_params($conn, $sql, $params);

    if ($result) {
      header('Location: thank-you.php');
      exit();
    } else {
      $error_message = "Gagal menyimpan ke database: " . pg_last_error($conn);
    }
  } else {
    $error_message = "Mohon lengkapi semua field yang wajib diisi!";
  }
}
?>
<!DOCTYPE html>
<html lang="id">

<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Kuesioner Kepuasan Pasien - RS Ekahusada</title>
  <link rel="stylesheet" href="style.css">
</head>

<body>
  <div class="container">

    <div class="header">
      <div class="header-logo">
        <div class="logo-container">
          <img src="images/logo.png" alt="Logo RS Ekahusada" class="logo-icon">
        </div>

        <div class="header-text">
          <h1>RS EKAHUSADA</h1>
          <p>KUESIONER SURVEI KEPUASAN PASIEN</p>
        </div>
      </div>
    </div>

    <div class="form-container">
      <?php if (isset($error_message)): ?>
        <div class="error-message" style="background: #fee; color: #c00; padding: 15px; border-radius: 8px; margin-bottom: 20px; border-left: 4px solid #c00; font-weight: 500;">
          ⚠️ <?php echo htmlspecialchars($error_message); ?>
        </div>
      <?php endif; ?>

      <form method="POST" action="">
        <div class="date-time-section">
          <div class="input-group">
            <label for="surveyDate">
              <span style="color: #00b3b3; margin-right: 5px;">📅</span> Tanggal Survei
            </label>
            <input type="date" id="surveyDate" name="surveyDate" required>
          </div>
          <div class="input-group">
            <label for="surveyTime">
              <span style="color: #00b3b3; margin-right: 5px;">⏰</span> Jam Survei
            </label>
            <select id="surveyTime" name="surveyTime" required>
              <option value="">Pilih Jam</option>
              <option value="08-12">08.00 - 12.00 WIB</option>
              <option value="12-18">12.00 - 18.00 WIB</option>
            </select>
          </div>
        </div>

        <h2 class="section-title">Profil Pasien</h2>
        <div class="profile-section">
          <div class="form-row">
            <div class="form-field">
              <label>Jenis Kelamin * <span style="color: #e74c3c;">(Pilih salah satu)</span></label>
              <div class="radio-group">
                <div class="radio-option">
                  <input type="radio" id="male" name="gender" value="male" required>
                  <label for="male">Laki-laki</label>
                </div>
                <div class="radio-option">
                  <input type="radio" id="female" name="gender" value="female">
                  <label for="female">Perempuan</label>
                </div>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-field">
              <label>Pendidikan * <span style="color: #e74c3c;">(Pilih salah satu)</span></label>
              <div class="radio-group">
                <div class="radio-option">
                  <input type="radio" id="sd" name="education" value="sd" required>
                  <label for="sd">SD</label>
                </div>
                <div class="radio-option">
                  <input type="radio" id="smp" name="education" value="smp">
                  <label for="smp">SMP</label>
                </div>
                <div class="radio-option">
                  <input type="radio" id="sma" name="education" value="sma">
                  <label for="sma">SMA</label>
                </div>
                <div class="radio-option">
                  <input type="radio" id="s1" name="education" value="s1">
                  <label for="s1">S1</label>
                </div>
                <div class="radio-option">
                  <input type="radio" id="s2" name="education" value="s2">
                  <label for="s2">S2</label>
                </div>
                <div class="radio-option">
                  <input type="radio" id="s3" name="education" value="s3">
                  <label for="s3">S3</label>
                </div>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-field">
              <label>Pekerjaan * <span style="color: #e74c3c;">(Pilih salah satu atau lebih)</span></label>
              <div class="checkbox-group">
                <div class="checkbox-option">
                  <input type="checkbox" id="pns" name="jobs[]" value="pns">
                  <label for="pns">PNS</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="tni" name="jobs[]" value="tni">
                  <label for="tni">TNI</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="polisi" name="jobs[]" value="polisi">
                  <label for="polisi">POLISI</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="swasta" name="jobs[]" value="swasta">
                  <label for="swasta">SWASTA</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="wirausaha" name="jobs[]" value="wirausaha">
                  <label for="wirausaha">WIRAUSAHA</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="petani" name="jobs[]" value="petani">
                  <label for="petani">PETANI</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="pelajar" name="jobs[]" value="pelajar">
                  <label for="pelajar">PELAJAR/MAHASISWA</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="lainnya" name="jobs[]" value="lainnya">
                  <label for="lainnya">LAINNYA</label>
                </div>
              </div>
            </div>
          </div>

          <div class="form-row">
            <div class="form-field">
              <label>Jenis Layanan * <span style="color: #e74c3c;">(Pilih salah satu atau lebih)</span></label>
              <div class="checkbox-group">
                <div class="checkbox-option">
                  <input type="checkbox" id="admissi" name="services[]" value="admissi">
                  <label for="admissi">ADMISI</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="igd" name="services[]" value="igd">
                  <label for="igd">IGD</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="lab" name="services[]" value="lab">
                  <label for="lab">LABORATORIUM</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="farmasi" name="services[]" value="farmasi">
                  <label for="farmasi">FARMASI</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="radiologi" name="services[]" value="radiologi">
                  <label for="radiologi">RADIOLOGI</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="gizi" name="services[]" value="gizi">
                  <label for="gizi">GIZI</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="icu" name="services[]" value="icu">
                  <label for="icu">ICU</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="operasi" name="services[]" value="operasi">
                  <label for="operasi">OPERASI</label>
                </div>
                <div class="checkbox-option">
                  <input type="checkbox" id="rawat_jalan" name="services[]" value="rawat_jalan">
                  <label for="rawat_jalan">RAWAT JALAN</label>
                </div>
              </div>
            </div>
          </div>
        </div>

        <h2 class="section-title">Pertanyaan Kepuasan Layanan</h2>
        <div class="scale-note">
          Skala Penilaian: 1 = Tidak Sesuai | 2 = Kurang Sesuai | 3 = Sesuai | 4 = Sangat Sesuai
        </div>

        <div class="questions-section">
          <div class="question-card">
            <div class="question-text">
              1. Bagaimana pendapat saudara tentang kesesuaian persyaratan pelayanan dengan jenis pelayanannya?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q1" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q1" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q1" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q1" value="4"><label>4</label></div>
            </div>
          </div>

          <div class="question-card">
            <div class="question-text">
              2. Bagaimana pemahaman Anda tentang kemudahan prosedur pelayanan di unit ini?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q2" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q2" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q2" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q2" value="4"><label>4</label></div>
            </div>
          </div>

          <div class="question-card">
            <div class="question-text">
              3. Bagaimana pendapat Anda tentang kecepatan waktu dalam memberikan pelayanan?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q3" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q3" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q3" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q3" value="4"><label>4</label></div>
            </div>
          </div>

          <div class="question-card">
            <div class="question-text">
              4. Bagaimana pendapat Anda tentang kewajaran biaya/tarif dalam pelayanan?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q4" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q4" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q4" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q4" value="4"><label>4</label></div>
            </div>
          </div>

          <div class="question-card">
            <div class="question-text">
              5. Bagaimana pendapat Anda tentang kesesuaian produk pelayanan antara yang tercantum dalam standar pelayanan dengan hasil yang diberikan?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q5" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q5" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q5" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q5" value="4"><label>4</label></div>
            </div>
          </div>

          <div class="question-card">
            <div class="question-text">
              6. Bagaimana pendapat Anda tentang kompetensi/kemampuan petugas dalam pelayanan?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q6" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q6" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q6" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q6" value="4"><label>4</label></div>
            </div>
          </div>

          <div class="question-card">
            <div class="question-text">
              7. Bagaimana pendapat Anda tentang perilaku petugas dalam pelayanan terkait kesopanan dan keramahan?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q7" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q7" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q7" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q7" value="4"><label>4</label></div>
            </div>
          </div>

          <div class="question-card">
            <div class="question-text">
              8. Bagaimana pendapat Anda tentang kualitas sarana dan prasarana?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q8" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q8" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q8" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q8" value="4"><label>4</label></div>
            </div>
          </div>

          <div class="question-card">
            <div class="question-text">
              9. Bagaimana pendapat Anda tentang penanganan pengaduan pengguna layanan?
            </div>
            <div class="question-options">
              <div class="option"><input type="radio" name="q9" value="1" required><label>1</label></div>
              <div class="option"><input type="radio" name="q9" value="2"><label>2</label></div>
              <div class="option"><input type="radio" name="q9" value="3"><label>3</label></div>
              <div class="option"><input type="radio" name="q9" value="4"><label>4</label></div>
            </div>
          </div>
        </div>

        <h2 class="section-title">Formulir Keluhan/Saran</h2>
        <div class="complaint-section">
          <div class="form-row">
            <div class="form-field">
              <label>Nama Pasien * <span style="color: #e74c3c;">(Contoh: Ahmad Suryadi)</span></label>
              <input type="text" name="nama_pasien" required placeholder="Contoh: Ahmad Suryadi">
            </div>
          </div>

          <div class="form-row">
            <div class="form-field">
              <label>Alamat * <span style="color: #e74c3c;">(Contoh: Jl. Merdeka No. 123, Jakarta)</span></label>
              <input type="text" name="alamat" required placeholder="Contoh: Jl. Merdeka No. 123, Jakarta">
            </div>
          </div>

          <div class="form-row">
            <div class="form-field">
              <label>Nomor HP * <span style="color: #e74c3c;">(Contoh: 081234567890)</span></label>
              <input type="tel" name="nomor_hp" required placeholder="Contoh: 081234567890">
            </div>
          </div>

          <div class="form-row">
            <div class="form-field">
              <label>Uraian Keluhan/Saran/Pertanyaan</label>
              <textarea name="keluhan" placeholder="Tuliskan keluhan, saran, atau pertanyaan Anda di sini..."></textarea>
            </div>
          </div>

          <div class="complaint-note">
            Masukan Anda sangat berarti bagi kami untuk meningkatkan kualitas layanan
          </div>
        </div>

        <button type="submit" class="submit-btn">Kirim Kuesioner</button>
      </form>
    </div>

    <footer class="footer">
      <div class="footer-content">
        <div style="display: flex; align-items: center; justify-content: center; gap: 10px; margin-bottom: 15px;">
          <h2>TERIMA KASIH</h2>
        </div>
        <p>Atas partisipasi Anda dalam mengisi kuesioner ini</p>
      </div>
    </footer>
  </div>
</body>

</html>
