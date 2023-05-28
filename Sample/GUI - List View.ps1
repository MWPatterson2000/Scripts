# Create the form
$sampleForm = New-Object System.Windows.Forms.Form
$sampleForm.Width = 300
$sampleForm.Height = 300
# Create three ListViewItems
$item1 = New-Object System.Windows.Forms.ListViewItem('Item 1')
$item1.SubItems.Add('John')
$item1.SubItems.Add('Smith')
$item2 = New-Object System.Windows.Forms.ListViewItem('Item 2')
$item2.SubItems.Add('Jane')
$item2.SubItems.Add('Doe')
$item3 = New-Object System.Windows.Forms.ListViewItem('Item 3')
$item3.SubItems.Add('Uros')
$item3.SubItems.Add('Calakovic')

# Create a ListView, set the view to 'Details' and add columns
$listView = New-Object System.Windows.Forms.ListView
$listView.View = 'Details'
$listView.Width = 300
$listView.Height = 300
$listView.Columns.Add('Item')
$listView.Columns.Add('First Name')
$listView.Columns.Add('Last Name')
# Add items to the ListView
$listView.Items.AddRange(($item1, $item2, $item3))

# Add the ListView to the form and show the form
$sampleForm.Controls.Add($listView)
[void] $sampleForm.ShowDialog()