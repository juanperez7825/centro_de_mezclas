function submitZPL(value) {
  // Get the ZPL data from the textarea
  const zplData = value;

  // Create a form element dynamically
  const form = document.createElement('form');
  form.id = 'zplForm';
  form.method = 'POST';
  form.action = 'https://www.webprinter.online';  // Replace with the actual URL
  form.target = '_blank';  // Open the form submission in a new tab/window

  // Create a hidden textarea input to hold the ZPL data
  const hiddenField = document.createElement('textarea');
  hiddenField.name = 'zplData';  // The name of the field to be submitted
  hiddenField.value = zplData;

    const copiesField = document.createElement('input');
    copiesField.type = 'hidden';
    copiesField.name = 'copies';
    const copiesElement = document.getElementById('frmPrintSelect:catImp_input');
    copiesField.value = copiesElement ? copiesElement.value : 1;

  const csrfField = document.createElement('input');
  csrfField.type = 'hidden';
  csrfField.name = '_csrf_token';
  csrfField.value = 'AxU3AnMNBDVLImoeNiMnKkN5SSVbHiZVwEPXKXNv2R0kyUbF-83D4xq6';

  // Append the hidden field to the form
  form.appendChild(hiddenField);
  form.appendChild(csrfField);
  form.appendChild(copiesField);

  // Append the form to the body and submit it
  document.body.appendChild(form);
  form.submit();

  // Remove the form from the DOM after submission
  document.body.removeChild(form);
}
