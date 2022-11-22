using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VolumeLightInstance : MonoBehaviour
{
    private static readonly int _colorPropertyId = Shader.PropertyToID("_Color");
    private static readonly int _flickerPropertyId = Shader.PropertyToID("_Flicker");
    private static readonly int _normalsInfluencePropertyId = Shader.PropertyToID("_NormalsInfluence");

    [ColorUsage(false, true)] public Color Color = new Color(1f, 1f, 1f, 0f);
    [Range(0f, 1f)] public float FlickerIntensity = 0.5f;
    [Range(0f, 1f)] public float NormalsInfluence = 1.0f;
    [HideInInspector] [SerializeField] private Renderer thisRenderer;

#if UNITY_EDITOR
    private void OnValidate()
    {
        if (!thisRenderer)
        {
            thisRenderer = GetComponent<Renderer>();
        }

        UpdateProperties();
    }
#endif

    private void OnBecameVisible()
    {
#if !UNITY_EDITOR
        UpdateProperties();
#endif

#if UNITY_EDITOR
        if (Application.isPlaying && gameObject.scene != null)
#endif
        {
            Destroy(this);
        }
    }

    private void UpdateProperties()
    {
        if (thisRenderer)
        {
            var propertyBlock = new MaterialPropertyBlock();
            propertyBlock.SetColor(_colorPropertyId, Color);
            propertyBlock.SetFloat(_flickerPropertyId, FlickerIntensity);
            propertyBlock.SetFloat(_normalsInfluencePropertyId, NormalsInfluence);

            thisRenderer.SetPropertyBlock(propertyBlock);
        }
    }
}