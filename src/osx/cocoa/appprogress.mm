/////////////////////////////////////////////////////////////////////////////
// Name:        src/osx/cocoa/appprogress.mm
// Purpose:     wxAppProgressIndicator OSX implemenation
// Author:      Tobias Taschner
// Created:     2014-10-22
// Copyright:   (c) 2014 wxWidgets development team
// Licence:     wxWindows licence
/////////////////////////////////////////////////////////////////////////////

#include "wx/appprogress.h"
#include "wx/osx/private.h"

@interface wxLDAppProgressDockIcon : NSObject
{
    NSProgressIndicator* m_progIndicator;
    NSDockTile* m_dockTile;
}

- (id)init;

- (void)setProgress: (double)value;

@end

@implementation wxLDAppProgressDockIcon

- (id)init
{
    if (self = [super init])
    {
        m_dockTile = [NSApplication sharedApplication].dockTile;
        NSImageView* iv = [[NSImageView alloc] init];
        [iv setImage:[NSApplication sharedApplication].applicationIconImage];
        [m_dockTile setContentView:iv];
        [iv release];
        
        m_progIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0.0f, 16.0f, m_dockTile.size.width, 24.)];
        m_progIndicator.style = NSProgressIndicatorBarStyle;
        [m_progIndicator setIndeterminate:NO];
        [iv addSubview:m_progIndicator];
        
        [m_progIndicator setBezeled:YES];
        [m_progIndicator setMinValue:0];
        [m_progIndicator setMaxValue:1];
        [self setProgress:0.0];
    }
    return self;
}

- (void)dealloc
{
    [m_progIndicator release];
    [super dealloc];
}

- (void)setProgress: (double)value
{
    [m_progIndicator setHidden:NO];
    [m_progIndicator setIndeterminate:NO];
    [m_progIndicator setDoubleValue:value];
    
    [m_dockTile display];
}

- (void)setIndeterminate: (bool)indeterminate
{
    [m_progIndicator setHidden:NO];
    [m_progIndicator setIndeterminate:indeterminate];

    [m_dockTile display];
}

- (void)reset
{
    [m_progIndicator setHidden:YES];

    [m_dockTile display];
}

@end

wxAppProgressIndicator::wxAppProgressIndicator(wxWindow* WXUNUSED(parent), int maxValue ):
    m_maxValue(maxValue)
{
    wxLDAppProgressDockIcon* dockIcon = [[wxLDAppProgressDockIcon alloc] init];
    
    m_dockIcon = dockIcon;
}

wxAppProgressIndicator::~wxAppProgressIndicator()
{
    Reset();

    NSObject* obj = (NSObject*) m_dockIcon;
    [obj release];
}

bool wxAppProgressIndicator::IsAvailable() const
{
    return true;
}

void wxAppProgressIndicator::SetValue(int value)
{
    wxLDAppProgressDockIcon* dockIcon = (wxLDAppProgressDockIcon*) m_dockIcon;
    [dockIcon setProgress:(double)value / (double)m_maxValue];
}

void wxAppProgressIndicator::SetRange(int range)
{
    m_maxValue = range;
}

void wxAppProgressIndicator::Pulse()
{
    wxLDAppProgressDockIcon* dockIcon = (wxLDAppProgressDockIcon*) m_dockIcon;
    [dockIcon setIndeterminate:true];
}

void wxAppProgressIndicator::Reset()
{
    wxLDAppProgressDockIcon* dockIcon = (wxLDAppProgressDockIcon*) m_dockIcon;
    [dockIcon reset];
}
