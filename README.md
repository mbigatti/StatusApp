# StatusApp

![icon](http://cl.ly/YQ81/Icon-Small-40@3x.png)

This is a complete Swift project for a status tracking App for educational purposes. It can manage a list of entries. Each entry contains a title, notes and last edit date. User can also choose the entry color. The entry row adjust height to accomodate all the notes text.

![main view](http://cl.ly/image/0x3H1W3V450J/download/StatusApp1.png)

In the detail view user can choose entry color in a palette of five predefined colors. The notes text field grows as the user write. Text field accent color is chosen by the app using the selected entry color.

![detail view with keyboard](http://cl.ly/image/053a2Y1j3Z0D/download/StatusApp3.png)
![detail view](http://cl.ly/image/2T3P0P3G2f47/download/StatusApp2.png)

## Technologies
Brief list of technologies and API used in the source code:

- storyboard based project
- xib for launch screen
- automatic dynamic `UITableView` row height
- empty state manager with specific `UITableViewDataSource`
- custom `UITableViewCell`
- row deletion using `UITableViewDelegate`
- custom components inspectable in Interface Builder
- custom component with Core Graphics drawing
- custom component with Core Graphics gradients
- custom auto-growing `UITextView` for data entry
- view background color fading with Core Animation
- `NSKeyedArchiver` and `NSKeyedUnarchiver`
- mix and match with Objective-C code

### Contact
[http://bigatti.it](http://bigatti.it)  
[@mbigatti](https://twitter.com/mbigatti)
