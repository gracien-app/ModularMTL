// Source:
// Slightly modified keyboard input handling from
// https://github.com/twohyjr/Metal-Game-Engine-Tutorial
//

import Foundation

public enum KeyCodes: UInt16 {
    //Special Chars
    case space             = 0x31
    case returnKey         = 0x24
    case enterKey          = 0x4C
    case escape            = 0x35
    case shift             = 0x39
    case command           = 0x37
    
    //DPad Keys
    case leftArrow         = 0x7B
    case rightArrow        = 0x7C
    case downArrow         = 0x7D
    case upArrow           = 0x7E
    
    //Alphabet
    case a                 = 0x00
    case b                 = 0x0B
    case c                 = 0x08
    case d                 = 0x02
    case e                 = 0x0E
    case f                 = 0x03
    case g                 = 0x05
    case h                 = 0x04
    case i                 = 0x22
    case j                 = 0x26
    case k                 = 0x28
    case l                 = 0x25
    case m                 = 0x2E
    case n                 = 0x2D
    case o                 = 0x1F
    case p                 = 0x23
    case q                 = 0x0C
    case r                 = 0x0F
    case s                 = 0x01
    case t                 = 0x11
    case u                 = 0x20
    case v                 = 0x09
    case w                 = 0x0D
    case x                 = 0x07
    case y                 = 0x10
    case z                 = 0x06
}
