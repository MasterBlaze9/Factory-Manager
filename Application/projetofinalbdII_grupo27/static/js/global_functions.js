$(".default-value-1").change(function () {
  $(this).val() == "" || $(this).val() == "0" || $(this).val() == 0
    ? $(this).val(1)
    : $(this).val();
});

function checkDefaultVal(val) {
  return val == "" || val == null || val == undefined ? 1 : val;
}

function getBaseURL(indicator) {
  url = window.location.href;
  return url.substring(0, url.indexOf(indicator));
}

form = document.getElementsByTagName("form")[0].querySelectorAll("[required]");
form.forEach((input) => {
  const label = document.querySelector(`label[for="${input.id}"]`);
  if (label) {
    label.innerHTML += '<span style="color: red;"> *</span>';
  }
});
