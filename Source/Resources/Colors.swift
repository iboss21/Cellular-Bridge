import UIKit

struct AppColors {
    static let shared = AppColors()
    
    // Brand Colors
    let primary = UIColor(hex: "#007AFF")
    let secondary = UIColor(hex: "#5856D6")
    let accent = UIColor(hex: "#FF2D55")
    
    // Status Colors
    let success = UIColor(hex: "#34C759")
    let warning = UIColor(hex: "#FF9500")
    let error = UIColor(hex: "#FF3B30")
    
    // Background Colors
    let background = UIColor(hex: "#F2F2F7")
    let cardBackground = UIColor(hex: "#FFFFFF")
    let secondaryBackground = UIColor(hex: "#E5E5EA")
    
    // Text Colors
    let primaryText = UIColor(hex: "#000000")
    let secondaryText = UIColor(hex: "#8E8E93")
    let tertiaryText = UIColor(hex: "#C7C7CC")
    
    // Gradient Colors
    struct Gradients {
        static let primary = [
            UIColor(hex: "#007AFF").cgColor,
            UIColor(hex: "#5856D6").cgColor
        ]
        
        static let secondary = [
            UIColor(hex: "#FF2D55").cgColor,
            UIColor(hex: "#FF9500").cgColor
        ]
    }
}
