using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(VolumeLightInstance))]
public class VolumeLightInstanceEditor : Editor
{
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        
        EditorGUILayout.HelpBox("Note: If the DepthNormals prepass is not enabled, then there will be no influence from normals on Volume Lights, and if \"Normals Influence\" is set to 1, the light will not be visible at all.  To enable the DepthNormals prepass, your main Renderer must have either an \"Enable Depth Normals\" Renderer Feature, or a \"Screen Space Ambient Occlusion\" Renderer Feature with the depth \"Source\" mode set to \"Depth Normals.\"", MessageType.Info);
    }
}
