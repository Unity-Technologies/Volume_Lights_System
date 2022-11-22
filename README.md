# Volume Lights System

The purpose of this project is to demonstrate how URP's "DepthNormals" prepass can be used to render approximated point lights using specially-shaded meshes instead of actual lights.  This effect is especially useful for adding exaggerated stylized lighting.

## Notable Included Assets

- A prefab which can be added to scenes to create Volume Lights
	- The prefab also has a VolumeLightInstance component on it, which uses PropertyBlocks to set per-renderer material values while maintaining GPU instancing support.
- A URP Renderer Feature specifically for enabling the DepthNormals prepass, so that users do not need to enable it by adding the SSAO Renderer Feature's and setting its Source property to "Depth Normals" (the only place it can be specified in vanilla URP).
	- Note: if the DepthNormals prepass is not enabled by some means, then Volume Lights will still work, but their "Normals Influence" should be set to 0 to ensure visibility.

## Installation

The best way to install this package is to download it via the VolumeLightsSystem.unitypackage available in the [Releases](https://github.com/Unity-Technologies/Volume_Lights_System/releases/) section.

1. Download the VolumeLightsSystem.unitypackage from the [Releases](https://github.com/Unity-Technologies/Volume_Lights_System/releases/) section.
2. Import VolumeLightsSystem.unitypackage into your URP project.
3. Add VolumeLight prefabs to your scenes as desired.

## Performance Implications

While the shaders for this effect are relatively inexpensive, they are not "free".  In particular, the lighting effect's shader uses Additive blending in the Transparent pass; this means that when several of these lights are viewed stacked in front of one another, they will have overdraw impacts (pixels will draw once per Volume Light in that pixel).  Overdraw can be very costly on some lower-power devices, such as mobile phones.  So - make sure to test the performance in your particular project, and on your target devices, to ensure this effect provides acceptable performance for your scenarios.