<?php
session_start();
require_once "config.php";

$conn = pg_connect("host=$db_host port=$db_port dbname=$db_name user=$db_user password=$db_pass");
if (!$conn) {
  die("Koneksi PostgreSQL gagal: " . htmlspecialchars(pg_last_error()));
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
  $required = ['nama_pasien','alamat','nomor_hp'];

  $valid = true;
  foreach ($required as $r) {
    if (!isset($_POST[$r]) || trim((string)$_POST[$r]) === '') {
      $valid = false;
      break;
    }
  }

  if ($valid) {
    $sql = "INSERT INTO keluhan (nama_pasien, alamat, nomor_hp, keluhan)
            VALUES ($1,$2,$3,$4)";

    $params = [
      trim((string)$_POST['nama_pasien']),
      trim((string)$_POST['alamat']),
      trim((string)$_POST['nomor_hp']),
      (isset($_POST['keluhan']) && trim((string)$_POST['keluhan']) !== '') ? trim((string)$_POST['keluhan']) : null
    ];

    $result = pg_query_params($conn, $sql, $params);

    if ($result) {
      header("Location: thank-you.php");
      exit;
    } else {
      $error = "Gagal menyimpan keluhan: " . pg_last_error($conn);
    }
  } else {
    $error = "Mohon lengkapi Nama, Alamat, dan Nomor HP.";
  }
}
?>
<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Form Keluhan & Saran Pasien</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="style.css">
</head>

<body>
<div class="container">

  <div class="header">
    <div class="header-logo">
      <div class="logo-container">
        <img src="images/logo.png" class="logo-icon" alt="Logo RS Ekahusada">
      </div>
      <div class="header-text">
        <h1>RS EKAHUSADA</h1>
        <p>FORMULIR KELUHAN & SARAN PASIEN</p>
      </div>
    </div>
  </div>

  <div class="form-container">
    <h2 class="section-title">🗣️ Formulir Keluhan / Saran</h2>

    <?php if (isset($error)): ?>
      <div class="error-message" style="background:#fee;color:#c00;padding:15px;border-radius:8px;margin-bottom:20px;border-left:4px solid #c00;font-weight:500;">
        ⚠️ <?php echo htmlspecialchars($error); ?>
      </div>
    <?php endif; ?>

    <form method="POST" action="">
      <div class="form-row">
        <div class="form-field">
          <label>Nama Pasien *</label>
          <input type="text" name="nama_pasien" class="input-control" required>
        </div>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>Alamat *</label>
          <input type="text" name="alamat" class="input-control" required>
        </div>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>Nomor HP *</label>
          <input type="tel" name="nomor_hp" class="input-control" required>
        </div>
      </div>

      <div class="form-row">
        <div class="form-field">
          <label>Uraian Keluhan / Saran / Pertanyaan</label>
          <textarea name="keluhan" class="textarea-control"
            placeholder="Tuliskan keluhan, saran, atau pertanyaan Anda di sini..."></textarea>
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
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="white" stroke="none">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
          </svg>
          <h2>TERIMA KASIH</h2>
          <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="white" stroke="none">
            <path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z" />
          </svg>
        </div>
        <p>Atas partisipasi Anda dalam mengisi kuesioner ini</p>

        <div class="footer-contact">
          <h3>Saluran Keluhan & Saran</h3>
          <div class="contact-cards">
            <div class="contact-card">
              <h3 style="font-size: 16px; font-weight: bold; margin-bottom: 5px; display: flex; align-items: center; justify-content: center; gap: 8px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z" />
                  <polyline points="22 6 12 13 2 6" />
                </svg>
                Kotak Saran
              </h3>
              <p>Tersedia di lobi rumah sakit</p>
            </div>
            <div class="contact-card">
              <h3 style="font-size: 16px; font-weight: bold; margin-bottom: 5px; display: flex; align-items: center; justify-content: center; gap: 8px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z" />
                </svg>
                Humas
              </h3>
              <p>Hubungi bagian Humas kami</p>
            </div>
            <div class="contact-card">
              <h3 style="font-size: 16px; font-weight: bold; margin-bottom: 5px; display: flex; align-items: center; justify-content: center; gap: 8px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" />
                </svg>
                WA Pengaduan
              </h3>
              <p>082244125457</p>
            </div>
          </div>
        </div>

        <div style="margin-top: 20px; font-size: 14px; color: rgba(255,255,255,0.8);">
          <p>RS Ekahusada - Melayani Dengan Sepenuh Hati</p>
        </div>
      </div>
    </footer>

</div>
</body>
</html>
        