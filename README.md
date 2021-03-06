# ASJExpandableTextView

UITextView's most obvious omission is the ability to set placeholder text. This class fixes that and provides more. You can make the text view expand and contract according to its content and have a "Done" button over the keyboard to hide it.

![alt tag](Images/Screenshot.png)

# Installation

Cocoapods is the preferred way to install this library. Add this command to your `Podfile`:

```
pod 'ASJExpandableTextView'
```

# Usage

Creating an ASJExpandableTextView is easy. It has a simple interface consisting of four properties which are IBInspectable. This means that they can be set using the interface builder of your choice; Xibs or Storyboards.

```
@property (copy, nonatomic) IBInspectable NSString *placeholder;
```
Sets the placeholder. Visible when there is nothing typed in the text view.

```
@property (nonatomic) IBInspectable BOOL isExpandable;
```
Set this to make the text view expand and contract according to its content.

```
@property (nonatomic) IBInspectable NSUInteger maximumLineCount;
```
You can set the number of visible lines of the text view. Default is 4. To use this property, `isExpandable` must be set to `YES`.

```
@property (nonatomic) IBInspectable BOOL shouldShowDoneButtonOverKeyboard;
```
The "return" key on the keyboard for a `UITextView` brings a new line, unlike a `UITextField` where the keyboard gets hidden. Set this property to show a "Done" button over the keyboard which can hide the keyboard.

```
@property (copy) DoneTappedBlock doneTappedBlock;
```
You can handle the event of the keyboard getting hidden using this block. To use this property, `shouldShowDoneButtonOverKeyboard` must be set to `YES`.

![alt tag](Images/IBInspectable.png)

You can create one using just the interface builder, drop in a UITextView and change the class to `ASJExpandableTextView`.

![alt tag](Images/CustomClass.png)

###Thanks

- To [Abhijit Kayande](https://github.com/Abhijit-Kayande) for fixing the choppy animation

# License

ASJExpandableTextView is available under the MIT license. See the LICENSE file for more info.
