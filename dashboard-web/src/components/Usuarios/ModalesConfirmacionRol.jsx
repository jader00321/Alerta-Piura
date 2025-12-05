/*// src/components/Usuarios/ModalesConfirmacionRol.jsx
import React from 'react';
import {
  Dialog, DialogActions, DialogContent, DialogContentText,
  DialogTitle, TextField, Button, Box, Typography
} from '@mui/material';
import { 
  AdminPanelSettings as AdminPanelSettingsIcon, 
  Group as GroupIcon, 
  Mic as MicIcon,
  WarningAmber as WarningIcon
  
} from '@mui/icons-material';

// --- Modal genérico para roles simples (Líder, Reportero) ---
const ModalPromocionSimple = ({ open, onClose, onConfirm, roleConfig }) => {
  const { type, Icon, color, lightColor } = roleConfig;
  
  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle sx={{ fontWeight: 'bold' }}>Confirmar Promoción</DialogTitle>
      <DialogContent sx={{ p: 0 }}>
        <Box 
          sx={{ 
            bgcolor: lightColor, 
            color: color, 
            p: 3,
            display: 'flex',
            alignItems: 'center',
            gap: 2
          }}
        >
          <Icon sx={{ fontSize: 40 }} />
          <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
            Promover a {type}
          </Typography>
        </Box>
        <DialogContentText sx={{ p: 3, pb: 1 }}>
          ¿Estás seguro de que quieres promover a este usuario al rol de **{type}**?
        </DialogContentText>
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose}>Cancelar</Button>
        <Button onClick={onConfirm} variant="contained" sx={{ bgcolor: color, '&:hover': { bgcolor: color } }}>
          Confirmar
        </Button>
      </DialogActions>
    </Dialog>
  );
};

// --- Modal de Seguridad para Admin ---
const ModalPromocionAdmin = ({ open, onClose, onConfirm, adminPassword, setAdminPassword, confirmText, setConfirmText }) => {
  return (
    <Dialog open={open} onClose={onClose}>
      <DialogTitle sx={{ fontWeight: 'bold' }}>Confirmación de Seguridad</DialogTitle>
      <DialogContent>
        <Box 
          sx={{ 
            bgcolor: 'secondary.light', 
            color: 'secondary.dark', 
            p: 3, mb: 2,
            display: 'flex',
            alignItems: 'center',
            gap: 2,
            borderRadius: 1
          }}
        >
          <AdminPanelSettingsIcon sx={{ fontSize: 40 }} />
          <Typography variant="h6" sx={{ fontWeight: 'bold' }}>
            Promoción a Administrador
          </Typography>
        </Box>
        <DialogContentText sx={{ display: 'flex', gap: 1, alignItems: 'center' }}>
          <WarningIcon color="error" fontSize="small" />
          Está a punto de otorgar privilegios de **Administrador**.
        </DialogContentText>
        <DialogContentText sx={{ mt: 1, mb: 2 }}>
          Para continuar, escriba "PROMOVER" y su contraseña actual.
        </DialogContentText>
        <TextField 
          autoFocus 
          margin="dense" 
          label='Escriba "PROMOVER"' 
          type="text" 
          fullWidth 
          variant="outlined" 
          value={confirmText} 
          onChange={(e) => setConfirmText(e.target.value)} 
        />
        <TextField 
          margin="dense" 
          label="Su Contraseña de Administrador" 
          type="password" 
          fullWidth 
          variant="outlined" 
          value={adminPassword} 
          onChange={(e) => setAdminPassword(e.target.value)} 
        />
      </DialogContent>
      <DialogActions sx={{ p: 2 }}>
        <Button onClick={onClose}>Cancelar</Button>
        <Button 
          onClick={onConfirm} 
          variant="contained" 
          color="error" 
          disabled={confirmText !== 'PROMOVER' || !adminPassword}
        >
          Confirmar Promoción
        </Button>
      </DialogActions>
    </Dialog>
  );
};

// --- Componente principal renombrado ---
function ModalesConfirmacionRol(props) {
  const { promoModal, ...rest } = props;

  if (promoModal.type === 'lider_vecinal') {
    return (
      <ModalPromocionSimple
        open={promoModal.open}
        onClose={props.onClose}
        onConfirm={props.onConfirm}
        roleConfig={{ 
          type: 'Líder Vecinal', 
          Icon: GroupIcon, 
          color: 'primary.dark', 
          lightColor: 'primary.light' 
        }}
      />
    );
  }

  if (promoModal.type === 'reportero') {
    return (
      <ModalPromocionSimple
        open={promoModal.open}
        onClose={props.onClose}
        onConfirm={props.onConfirm}
        roleConfig={{ 
          type: 'Reportero / Prensa', 
          Icon: MicIcon, 
          color: 'info.dark', 
          lightColor: 'info.light' 
        }}
      />
    );
  }

  if (promoModal.type === 'admin') {
    return (
      <ModalPromocionAdmin
        open={promoModal.open}
        {...rest}
      />
    );
  }

  return null; // No mostrar nada si el tipo no coincide
}

export default ModalesConfirmacionRol;*/

// src/components/Usuarios/ModalesConfirmacionRol.jsx
import React from 'react';
import {
  Dialog,
  DialogActions,
  DialogContent,
  DialogTitle,
  TextField,
  Button,
  Box,
  Typography,
  Avatar,
  Slide,
  InputAdornment,
  useTheme,
  alpha
} from '@mui/material';
import {
  AdminPanelSettings as AdminPanelSettingsIcon,
  Group as GroupIcon,
  Mic as MicIcon,
  WarningAmber as WarningAmberIcon,
  Key as KeyIcon,
  TextFormat as TextIcon,
  CheckCircle as CheckIcon,
  Cancel as CancelIcon
} from '@mui/icons-material';

// --- Transición suave para los modales ---
const Transition = React.forwardRef(function Transition(props, ref) {
  return <Slide direction="up" ref={ref} {...props} />;
});

// --- Modal genérico para roles simples (Diseño Visual Mejorado) ---
const ModalPromocionSimple = ({ open, onClose, onConfirm, roleConfig }) => {
  const { type, Icon, colorMain } = roleConfig;
  const theme = useTheme();

  return (
    <Dialog 
      open={open} 
      onClose={onClose}
      TransitionComponent={Transition}
      keepMounted
      maxWidth="xs"
      fullWidth
      PaperProps={{
        sx: {
          borderRadius: 3,
          overflow: 'hidden',
          boxShadow: theme.shadows[10]
        }
      }}
    >
      {/* Encabezado con Degradado Dinámico */}
      <Box sx={{ 
        background: `linear-gradient(135deg, ${alpha(colorMain, 0.2)} 0%, ${alpha(theme.palette.background.paper, 0.8)} 100%)`,
        p: 4,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        borderBottom: `1px solid ${alpha(colorMain, 0.1)}`
      }}>
        <Avatar sx={{ 
          bgcolor: colorMain, 
          width: 64, height: 64, 
          boxShadow: `0 4px 12px ${alpha(colorMain, 0.4)}`,
          mb: 2
        }}>
          <Icon sx={{ fontSize: 32, color: '#fff' }} />
        </Avatar>
        
        <Typography variant="h5" sx={{ fontWeight: 700, textAlign: 'center' }}>
          Promover a {type}
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mt: 1, textAlign: 'center' }}>
          Confirmación de cambio de rol
        </Typography>
      </Box>

      <DialogContent sx={{ px: 4, py: 3, textAlign: 'center' }}>
        <Typography variant="body1">
          ¿Estás seguro de otorgar los permisos de <strong>{type}</strong> a este usuario?
        </Typography>
      </DialogContent>

      <DialogActions sx={{ p: 3, pt: 0, justifyContent: 'center', gap: 2 }}>
        <Button 
          onClick={onClose} 
          variant="outlined" 
          color="inherit" 
          startIcon={<CancelIcon />}
          sx={{ borderRadius: 2, px: 3 }}
        >
          Cancelar
        </Button>
        <Button 
          onClick={onConfirm} 
          variant="contained" 
          startIcon={<CheckIcon />}
          sx={{ 
            bgcolor: colorMain, 
            borderRadius: 2, 
            px: 3,
            '&:hover': { bgcolor: alpha(colorMain, 0.9) } 
          }}
        >
          Confirmar
        </Button>
      </DialogActions>
    </Dialog>
  );
};

// --- Modal de Seguridad para Admin (Diseño Crítico Profesional) ---
const ModalPromocionAdmin = ({ open, onClose, onConfirm, adminPassword, setAdminPassword, confirmText, setConfirmText }) => {
  const theme = useTheme();
  const criticalColor = theme.palette.error.main;

  return (
    <Dialog 
      open={open} 
      onClose={onClose}
      TransitionComponent={Transition}
      maxWidth="sm"
      fullWidth
      PaperProps={{
        sx: { borderRadius: 3, boxShadow: theme.shadows[20] }
      }}
    >
      <DialogTitle sx={{ 
        bgcolor: alpha(criticalColor, 0.08), 
        color: criticalColor,
        display: 'flex', 
        alignItems: 'center', 
        gap: 1.5,
        borderBottom: `1px solid ${alpha(criticalColor, 0.1)}`
      }}>
        <WarningAmberIcon />
        {/* CORRECCIÓN AQUÍ: Agregamos component="span" para evitar el error de h6 dentro de h2 */}
        <Typography variant="h6" fontWeight="bold" component="span">
          Zona de Peligro: Admin
        </Typography>
      </DialogTitle>

      <DialogContent sx={{ pt: 3 }}>
        <Box sx={{ display: 'flex', flexDirection: 'column', alignItems: 'center', mb: 3, mt: 1 }}>
          <Avatar sx={{ bgcolor: criticalColor, width: 56, height: 56, mb: 2 }}>
            <AdminPanelSettingsIcon sx={{ fontSize: 30 }} />
          </Avatar>
          <Typography variant="h6" align="center" gutterBottom>
            Promoción a Administrador
          </Typography>
          <Typography variant="body2" color="text.secondary" align="center">
            Esta acción otorgará <strong>control total</strong> sobre la plataforma.
            Se requiere doble verificación.
          </Typography>
        </Box>

        <Box component="form" sx={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          <TextField 
            label="1. Escriba la palabra clave" 
            placeholder='Escriba "PROMOVER"'
            fullWidth 
            value={confirmText} 
            onChange={(e) => setConfirmText(e.target.value)} 
            error={confirmText.length > 0 && confirmText !== 'PROMOVER'}
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <TextIcon color="action" />
                </InputAdornment>
              ),
            }}
          />
          
          <TextField 
            label="2. Su contraseña de Administrador" 
            type="password" 
            fullWidth 
            value={adminPassword} 
            onChange={(e) => setAdminPassword(e.target.value)} 
            InputProps={{
              startAdornment: (
                <InputAdornment position="start">
                  <KeyIcon color="action" />
                </InputAdornment>
              ),
            }}
          />
        </Box>
      </DialogContent>

      <DialogActions sx={{ p: 3, pt: 1 }}>
        <Button onClick={onClose} size="large" color="inherit">
          Cancelar
        </Button>
        <Button 
          onClick={onConfirm} 
          variant="contained" 
          color="error"
          size="large"
          disabled={confirmText !== 'PROMOVER' || !adminPassword}
          startIcon={<AdminPanelSettingsIcon />}
          sx={{ borderRadius: 2, px: 4 }}
        >
          Otorgar Permisos
        </Button>
      </DialogActions>
    </Dialog>
  );
};

// --- Componente Principal ---
function ModalesConfirmacionRol(props) {
  const { promoModal, ...rest } = props;
  const theme = useTheme();

  // Mapeo de configuración visual según el tipo de rol
  // Nota: promoModal.type debe coincidir con los valores que envías desde PaginaUsuarios ('lider_vecinal', etc.)
  
  if (promoModal.type === 'lider_vecinal') {
    return (
      <ModalPromocionSimple
        open={promoModal.open}
        onClose={props.onClose}
        onConfirm={props.onConfirm}
        roleConfig={{ 
          type: 'Líder Vecinal', 
          Icon: GroupIcon, 
          // Usamos el color del tema directamente para consistencia
          colorMain: theme.palette.primary.main
        }}
      />
    );
  }

  if (promoModal.type === 'reportero') {
    return (
      <ModalPromocionSimple
        open={promoModal.open}
        onClose={props.onClose}
        onConfirm={props.onConfirm}
        roleConfig={{ 
          type: 'Reportero / Prensa', 
          Icon: MicIcon, 
          // Usamos el color Info del tema
          colorMain: theme.palette.info.main
        }}
      />
    );
  }

  if (promoModal.type === 'admin') {
    return (
      <ModalPromocionAdmin
        open={promoModal.open}
        {...rest}
      />
    );
  }

  return null;
}

export default ModalesConfirmacionRol;