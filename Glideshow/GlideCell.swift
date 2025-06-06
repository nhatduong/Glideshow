//
//  GlideCell.swift
//  Glideshow
//
//  Created by Visal Rajapakse on 2021-02-28.
//

import UIKit
import Combine

//MARK: Protocol - GlideableCellDelegate
/// Protocol to inform cell about scroll state
public protocol GlideableCellDelegate : AnyObject {
    
    /// Flag to set visibility of the content within the cell.
    var isProminent : Bool { set get }
    
    /// Optional protocol method to inform the cell to animate the views
    /// - Parameter offset: scrollView offset for view animation
    func cellDidGlide(offset : CGFloat)
}

class GlideCell: UICollectionViewCell {
    
    /// Content holder for subViews
    public var slide = UIView()
    
    /// Slide title font
    public var titleFont : UIFont?{
        didSet{
            slideTitle.font = titleFont
        }
    }
    
    /// Slide desctription font
    public var descriptionFont : UIFont?{
        didSet{
            slideDescription.font = descriptionFont
        }
    }
    
    /// Slide caption font
    public var captionFont : UIFont?{
        didSet{
            slideCaption.font = captionFont
        }
    }
    
    /// Slide insets
    public override var layoutMargins: UIEdgeInsets {
        didSet{
            layoutSubviews()
        }
    }
    
    // Protocol variable to hide/show labels based on value
    public var isProminent: Bool = true
    
    /// Sets up slide background image if image is available
    public var backgroundImage : UIImage? {
        didSet{
            slide.insertSubview(imageView, at: 0)
            imageView.frame = slide.bounds
            imageView.image = blurThenDarkenImage(image: (backgroundImage ?? UIImage(named: "thumbDefault"))!, blurRadius: 3, darkenAlpha: 0.4)
            
            
            slide.insertSubview(imageItemView, at: 2)
            imageItemView.frame = CGRect(x: 12, y: 12, width: 89, height: 139)
            imageItemView.image = backgroundImage
            imageItemView.contentMode = .scaleAspectFill
            imageItemView.layer.cornerRadius = 8
            imageItemView.layer.masksToBounds = true
            imageItemView.layer.borderWidth = 1
            imageItemView.layer.borderColor = UIColor.gray.cgColor
            
        }
    }
    
    /// Slide caption GlideLabel
    public var slideCaption : GlideLabel = {
        let label = GlideLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    /// Slide title GlideLabel
    public var slideTitle : GlideLabel = {
        let label = GlideLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    /// Slide description GlideLabel
    public var slideDescription : GlideLabel = {
        let label = GlideLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    /// Gradients
    public var isGradientEnabled : Bool = false {
        didSet{
            if isGradientEnabled {
                layoutGradient()
            }
        }
    }
    
    /// Gradient prominent color
    public var gradientColor : UIColor!{
        didSet{
            bottomGradient.colors = [UIColor.clear.cgColor, gradientColor.cgColor]
            isGradientEnabled = true
        }
    }
    
    
    /// Height of gradient view based on slide height
    public var gradientHeightFactor : CGFloat!{
        didSet{
            isGradientEnabled = true
            layoutGradient()
        }
    }
    
    /// View with gradient layer
    lazy var bottomGradientView : UIView = {
       let view = UIView()
        view.layer.insertSublayer(bottomGradient, at: 0)
        view.backgroundColor = .clear
        return view
    }()
    
    /// Gradient layer
    lazy var bottomGradient : CAGradientLayer = {
       let layer = CAGradientLayer()
        layer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor.copy(alpha: 0.6)!]
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 0, y: 1)
        layer.frame = CGRect.zero
        return layer
    }()
    
    /// Spacing between labels of the slide. Default value : 8
    public var labelSpacing : CGFloat!
    
    /// Animateable GlideLabels for gliding
    public var animateableViews : [GlideLabel]?
    
    /// glide factor for the title lable. Default: 2
    public var titleGlideFactor : CGFloat = 2 {
        didSet{
            slideTitle.glideFactor = titleGlideFactor
        }
    }
    
    /// glide factor for the description lable. Default: 2
    public var descriptionGlideFactor : CGFloat = 3 {
        didSet{
            slideDescription.glideFactor = titleGlideFactor
        }
    }
    
    /// glide factor for the title lable. Default: 2
    public var captionGlideFactor : CGFloat = 1 {
        didSet{
            slideCaption.glideFactor = titleGlideFactor
        }
    }
    
    /// Backround imageView for displaying images
    /// lazy property to prevent initialization if provided image is empty
    public lazy var imageView : UIImageView = {
       let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        return imgView
    }()
    
    public lazy var imageItemView : UIImageView = {
       let imageItemView = UIImageView()
        imageItemView.contentMode = .scaleAspectFill
        return imageItemView
    }()
    
    /// Maximum width of a GlideLabel. Calculated using leading inset of cell
    private var animateableMaxWidth : CGFloat!
    
    @available(iOS 13, *)
    private lazy var cancellable : AnyCancellable? = nil
        
    public override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if backgroundImage != nil {
            imageView.image = nil
            imageItemView.image = nil
        }
        if #available(iOS 13, *) {
            cancellable?.cancel()
        } else {
            return
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        // Setting up cell
        setAnimateableMaxWidth()
        setSlide()
        setupAnimateables()

    }
    
    private func initialize(){
        contentView.addSubview(slide)
        slide.addSubview(slideTitle)
        slide.addSubview(slideDescription)
        slide.addSubview(slideCaption)
        slide.backgroundColor = .clear
        slide.clipsToBounds = true
    }
    
    /// Configures cell
    /// - Parameter item: `GlideItem` to configure cell with
    public func configure( with item : GlideItem, placeholderImage : UIImage?){
        slideCaption.text = item.caption
        slideTitle.text = item.title
        slideDescription.text = item.description
        if let bgImage = item.backgroundImage{
            backgroundImage = bgImage
        }else{
            backgroundImage = placeholderImage

            if #available(iOS 13.0, *) {
                cancellable = loadImage(for: item).sink{
                    [weak self] image in self?.showNetworkImage(for: image)
                }
            } else {
                imageView.loadImage(urlString: item.imgURL!)
                imageItemView = imageView
            }
        }
        layoutIfNeeded()
    }
    
    
    /// Displays retrieved image
    /// - Parameter image: Image to display
    private func showNetworkImage(for image : UIImage?) {
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                    self.backgroundImage = image
        }, completion: nil)
    }
    
    
    /// Caches loaded image
    /// - Parameter item: `GlideItem` to retrieve URL
    /// - Returns: Returns `Just` publisher with the cached image if any.
    @available(iOS 13.0, *)
    private func loadImage(for item: GlideItem) -> AnyPublisher<UIImage?, Never> {
        return Just(item.imgURL)
         .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
            let url = URL(string: item.imgURL ?? "")!
             return ImageLoader.shared.loadImage(from: url)
         })
         .eraseToAnyPublisher()
     }

    
    /// Setup Description, Title, Caption in stated order by positioning based on each Glidelabels content
    private func setupAnimateables(){
        //setting up animateables
        setDescription()
        setTitle()
        setCaption()
        
        //adding GlideLabels for animations
        animateableViews = [slideCaption, slideTitle, slideDescription]
    }
    
    /// Lays out gradient if gradient is enabled
    private func layoutGradient(){
        guard gradientHeightFactor != nil else { return }

        bottomGradientView.removeFromSuperview()
        slide.insertSubview(bottomGradientView, at: 0)
        //height based on height factor
        let height = self.frame.height * gradientHeightFactor
        // Setting gradient frame
        bottomGradientView.frame = CGRect(
            x: 0,
            y: self.frame.height - height,
            width: self.frame.width,
            height: height)
        bottomGradient.frame = bottomGradientView.bounds
        setNeedsLayout()
    }
    
    /// Positioning title GlideLabel
    private func setTitle(){
        let titleHeight = slideTitle.getHeight(withMaxWidth: animateableMaxWidth)

        //setting frame
        slideTitle.frame = CGRect(x: 113, y: imageItemView.layoutMargins.top + 8, width: animateableMaxWidth, height: titleHeight)
    }
    
    /// Positioning description GlideLabel
    private func setDescription(){
        let descriptionHeight = slideDescription.getHeight(withMaxWidth: animateableMaxWidth)
        
        //setting frame
        slideDescription.frame = CGRect(x: 113, y: slide.frame.origin.y + 110, width: animateableMaxWidth, height: descriptionHeight)
    }
    
    /// Positioning caption GlideLabel
    private func setCaption(){
        let captionHeight = slideCaption.getHeight(withMaxWidth: animateableMaxWidth)

        //setting frame
        slideCaption.frame = CGRect(x: 113, y: slideTitle.frame.origin.y + slideTitle.frame.height + 4, width: animateableMaxWidth, height: captionHeight)
    }
    
    /// setting variable that holds maximum width of content in the slide
    private func setAnimateableMaxWidth(){
        animateableMaxWidth = slide.frame.width - layoutMargins.left - layoutMargins.right - 100
    }
        
    /// Sets content holder frame based on given slide type
    private func setSlide(){
        slide.frame = CGRect(
            x: layoutMargins.left,
            y: layoutMargins.top,
            width: contentView.frame.width - layoutMargins.left - layoutMargins.right,
            height: contentView.frame.height - layoutMargins.top - layoutMargins.bottom
        )
        slide.layer.cornerRadius = 10
    }
    
    private func setupBlurView(viewImg: UIView) {
//        viewImg.backgroundColor = .clear
        
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = viewImg.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.layer.opacity = 0.8

        viewImg.addSubview(blurEffectView)
    }
    
    private func blurThenDarkenImage(image: UIImage, blurRadius: Double, darkenAlpha: CGFloat) -> UIImage? {
        guard let ciImage = CIImage(image: image) else { return nil }

        // Step 1: Làm mờ
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(blurRadius, forKey: kCIInputRadiusKey)
        guard let blurredImage = blurFilter?.outputImage else { return nil }

        // Render ảnh mờ ra CGImage
        let context = CIContext()
        let cropRect = ciImage.extent
        guard let cgImageBlurred = context.createCGImage(blurredImage, from: cropRect) else { return nil }

        // Tạo UIImage từ CGImage
        let blurredUIImage = UIImage(cgImage: cgImageBlurred)

        // Vẽ lại ảnh với lớp phủ đen để làm tối
        UIGraphicsBeginImageContextWithOptions(blurredUIImage.size, false, blurredUIImage.scale)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }

        blurredUIImage.draw(at: .zero)

        ctx.setFillColor(UIColor(white: 0, alpha: darkenAlpha).cgColor)
        ctx.fill(CGRect(origin: .zero, size: blurredUIImage.size))

        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }



}

//MARK: Extensions - GlideableCellDelegate
/// GlideCellDelegate conformance
extension GlideCell : GlideableCellDelegate{
    
    /// Animates labels within cell based on `offset`
    /// - Parameter offset: Relative offset calculated by parent collectionView based on position for animation purposes
    public func cellDidGlide(offset: CGFloat) {
        
        // Returns if animateableViews are empty or nil
        guard animateableViews != nil && !(animateableViews?.isEmpty ?? false) else {return}
        
        // Variables to assign values corresponding to each label
        var glideFactor : CGFloat!
        var labelOffset : CGFloat!
        var alpha : CGFloat!

        // Traverses all animateables in animateableViews to glide and set alpha  based on calculated labelOffset
        animateableViews?.forEach{
            glideFactor = $0.glideFactor
            labelOffset =  (glideFactor * offset) + 113

            // setting alpha value of label based on current labelOffset
            if !isProminent && labelOffset != slide.layoutMargins.left {
                alpha = 0
            }else{
                alpha = 1 - abs(((offset * glideFactor) / self.frame.width) * glideFactor)
            }
            
            // Setting new values
            $0.alpha = alpha
            $0.frame.origin.x = labelOffset
        }
    }
}

